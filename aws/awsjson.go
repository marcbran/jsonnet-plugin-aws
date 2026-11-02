package aws

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
)

type awsJSON struct {
	version string
}

func (p awsJSON) encode(svc *Service, op *Operation, input map[string]any) (request, error) {
	body, err := svc.Model.encodeJSON(op.InputID(), nil, input, false)
	if err != nil {
		return request{}, err
	}
	if body == nil {
		body = map[string]any{}
	}
	b, err := json.Marshal(body)
	if err != nil {
		return request{}, err
	}
	h := http.Header{}
	h.Set("Content-Type", "application/x-amz-json-"+p.version)
	h.Set("X-Amz-Target", svc.Name()+"."+op.Name)
	return request{Method: http.MethodPost, Path: "/", Header: h, Body: b}, nil
}

func (p awsJSON) decode(svc *Service, op *Operation, resp response) (any, error) {
	if len(resp.Body) == 0 {
		return map[string]any{}, nil
	}
	var out any
	err := json.Unmarshal(resp.Body, &out)
	if err != nil {
		return nil, fmt.Errorf("decode response: %w", err)
	}
	return svc.Model.decodeJSON(op.OutputID(), nil, out, false), nil
}

func (p awsJSON) decodeError(resp response) apiError {
	var body map[string]any
	_ = json.Unmarshal(resp.Body, &body)
	code := resp.Header.Get("X-Amzn-Errortype")
	if code == "" {
		code = firstString(body, "__type", "code")
	}
	msg := firstString(body, "message", "Message", "errorMessage")
	if msg == "" {
		msg = strings.TrimSpace(string(resp.Body))
	}
	return apiError{Code: sanitizeErrorCode(code), Message: msg}
}

func firstString(m map[string]any, keys ...string) string {
	for _, k := range keys {
		if s, ok := m[k].(string); ok && s != "" {
			return s
		}
	}
	return ""
}

func sanitizeErrorCode(code string) string {
	code, _, _ = strings.Cut(code, ":")
	if i := strings.LastIndex(code, "#"); i >= 0 {
		code = code[i+1:]
	}
	return code
}
