package aws

import (
	"fmt"
	"net/http"
	"strings"
)

type restXML struct{}

func (p restXML) encode(svc *Service, op *Operation, input map[string]any) (request, error) {
	bound, err := svc.Model.bindRequest(op, input)
	if err != nil {
		return request{}, err
	}
	if len(bound.unbound) > 0 || bound.payload != nil {
		return request{}, fmt.Errorf("restXml request bodies are not supported")
	}
	return bound.request, nil
}

func (p restXML) decode(svc *Service, op *Operation, resp response) (any, error) {
	output, err := svc.Model.shape(op.OutputID())
	if err != nil {
		return nil, err
	}
	out := map[string]any{}
	svc.Model.decodeHTTPHeaders(output, resp.Header, out)
	for name, mem := range output.Members {
		if mem.Traits.Has("smithy.api#httpResponseCode") {
			out[name] = float64(resp.Status)
		}
	}
	if name, mem := payloadMember(output); mem != nil {
		target, err := svc.Model.shape(mem.Target)
		if err != nil {
			return nil, err
		}
		if len(resp.Body) == 0 {
			return out, nil
		}
		if target.Type == "structure" || target.Type == "union" {
			root, err := parseXML(resp.Body)
			if err != nil {
				return nil, fmt.Errorf("decode response: %w", err)
			}
			out[name] = svc.Model.decodeXML(mem.Target, mem.Traits, root)
		} else {
			out[name] = string(resp.Body)
		}
		return out, nil
	}
	if len(resp.Body) == 0 {
		return out, nil
	}
	root, err := parseXML(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("decode response: %w", err)
	}
	if op.Shape.Traits.Has("aws.customizations#s3UnwrappedXmlOutput") {
		for name, mem := range output.Members {
			if !httpBound(mem) {
				out[name] = svc.Model.decodeXML(mem.Target, mem.Traits, root)
			}
		}
		return out, nil
	}
	decoded, ok := svc.Model.decodeXML(op.OutputID(), nil, root).(map[string]any)
	if ok {
		for k, v := range decoded {
			out[k] = v
		}
	}
	return out, nil
}

func (p restXML) decodeError(resp response) apiError {
	if len(resp.Body) == 0 {
		return apiError{Code: strings.ReplaceAll(http.StatusText(resp.Status), " ", ""), Message: http.StatusText(resp.Status)}
	}
	root, err := parseXML(resp.Body)
	if err != nil {
		return apiError{Message: strings.TrimSpace(string(resp.Body))}
	}
	e := root
	if root.Name != "Error" {
		if nested := root.child("Error"); nested != nil {
			e = nested
		}
	}
	var code, msg string
	if c := e.child("Code"); c != nil {
		code = strings.TrimSpace(c.Text)
	}
	if m := e.child("Message"); m != nil {
		msg = strings.TrimSpace(m.Text)
	}
	if msg == "" {
		msg = strings.TrimSpace(string(resp.Body))
	}
	return apiError{Code: code, Message: msg}
}

func payloadMember(output *Shape) (string, *Member) {
	for name, mem := range output.Members {
		if mem.Traits.Has("smithy.api#httpPayload") {
			return name, mem
		}
	}
	return "", nil
}

func httpBound(mem *Member) bool {
	for _, trait := range []string{"smithy.api#httpHeader", "smithy.api#httpPrefixHeaders", "smithy.api#httpResponseCode", "smithy.api#httpPayload"} {
		if mem.Traits.Has(trait) {
			return true
		}
	}
	return false
}
