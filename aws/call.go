package aws

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"net/http"
	"time"

	v4 "github.com/aws/aws-sdk-go-v2/aws/signer/v4"
	"github.com/google/go-jsonnet"
	"github.com/google/go-jsonnet/ast"
	"github.com/marcbran/jpoet/pkg/jpoet"
)

type CallInput struct {
	Account   string
	Region    string
	Service   string
	Operation string
	Input     map[string]any
}

func Call(cfg *Config) jsonnet.NativeFunction {
	return jsonnet.NativeFunction{
		Name:   "call",
		Params: ast.Identifiers{"ctx", "service", "operation", "input"},
		Func: func(args []any) (any, error) {
			ci, err := parseCallInput(args)
			if err != nil {
				return nil, jpoet.NewFailure(http.StatusBadRequest, err.Error())
			}
			return runCall(context.Background(), cfg, ci)
		},
	}
}

func parseCallInput(args []any) (CallInput, error) {
	if len(args) != 4 {
		return CallInput{}, fmt.Errorf("expected ctx, service, operation, and input")
	}
	ctx, ok := args[0].(map[string]any)
	if !ok {
		return CallInput{}, fmt.Errorf("ctx must be an object")
	}
	account, ok := ctx["account"].(string)
	if !ok || account == "" {
		return CallInput{}, fmt.Errorf("ctx.account must be a non-empty string")
	}
	var region string
	if ctx["region"] != nil {
		region, ok = ctx["region"].(string)
		if !ok {
			return CallInput{}, fmt.Errorf("ctx.region must be a string")
		}
	}
	service, ok := args[1].(string)
	if !ok || service == "" {
		return CallInput{}, fmt.Errorf("service must be a non-empty string")
	}
	operation, ok := args[2].(string)
	if !ok || operation == "" {
		return CallInput{}, fmt.Errorf("operation must be a non-empty string")
	}
	input := map[string]any{}
	if args[3] != nil {
		input, ok = args[3].(map[string]any)
		if !ok {
			return CallInput{}, fmt.Errorf("input must be an object")
		}
	}
	return CallInput{
		Account:   account,
		Region:    region,
		Service:   service,
		Operation: operation,
		Input:     input,
	}, nil
}

func runCall(ctx context.Context, cfg *Config, ci CallInput) (any, error) {
	svc, err := cfg.registry.service(ci.Service)
	if err != nil {
		return nil, jpoet.NewFailure(http.StatusBadRequest, err.Error())
	}
	op, err := svc.Operation(ci.Operation)
	if err != nil {
		return nil, jpoet.NewFailure(http.StatusBadRequest, err.Error())
	}
	if !svc.Readable(op) {
		return nil, jpoet.NewFailure(http.StatusForbidden, fmt.Sprintf("%s %s is not an allowed read operation", svc.Key, op.Name))
	}
	endpoint, err := cfg.Endpoint(svc, ci.Region)
	if err != nil {
		return nil, jpoet.NewFailure(http.StatusBadRequest, err.Error())
	}
	req, err := svc.protocol.encode(svc, op, ci.Input)
	if err != nil {
		return nil, jpoet.NewFailure(http.StatusBadRequest, fmt.Sprintf("%s %s: %s", svc.Key, op.Name, err))
	}
	creds, err := cfg.Credentials(ctx, ci)
	if err != nil {
		return nil, jpoet.NewFailure(http.StatusUnauthorized, err.Error())
	}
	url := endpoint + req.Path
	if len(req.Query) > 0 {
		url += "?" + req.Query.Encode()
	}
	httpReq, err := http.NewRequestWithContext(ctx, req.Method, url, bytes.NewReader(req.Body))
	if err != nil {
		return nil, jpoet.NewFailure(http.StatusBadRequest, err.Error())
	}
	for k, vs := range req.Header {
		httpReq.Header[k] = vs
	}
	hash := sha256.Sum256(req.Body)
	payloadHash := hex.EncodeToString(hash[:])
	s3 := svc.SigningName == "s3"
	if s3 {
		httpReq.Header.Set("X-Amz-Content-Sha256", payloadHash)
	}
	signer := v4.NewSigner(func(o *v4.SignerOptions) {
		o.DisableURIPathEscaping = s3
	})
	err = signer.SignHTTP(ctx, creds, httpReq, payloadHash, svc.SigningName, svc.SigningRegion(ci.Region), time.Now())
	if err != nil {
		return nil, jpoet.NewFailure(http.StatusInternalServerError, err.Error())
	}
	httpResp, err := cfg.Client.Do(httpReq)
	if err != nil {
		return nil, jpoet.NewFailure(http.StatusBadGateway, err.Error())
	}
	body, err := io.ReadAll(httpResp.Body)
	closeErr := httpResp.Body.Close()
	if err != nil {
		return nil, jpoet.NewFailure(http.StatusBadGateway, err.Error())
	}
	if closeErr != nil {
		return nil, jpoet.NewFailure(http.StatusBadGateway, closeErr.Error())
	}
	resp := response{Status: httpResp.StatusCode, Header: httpResp.Header, Body: body}
	if resp.Status < 200 || resp.Status > 299 {
		e := svc.protocol.decodeError(resp)
		return nil, &jpoet.Failure{Code: resp.Status, Reason: e.Code, Message: e.Message}
	}
	out, err := svc.protocol.decode(svc, op, resp)
	if err != nil {
		return nil, jpoet.NewFailure(http.StatusBadGateway, err.Error())
	}
	return out, nil
}
