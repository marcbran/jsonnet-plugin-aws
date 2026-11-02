package aws

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
)

type restJSON struct{}

func (p restJSON) encode(svc *Service, op *Operation, input map[string]any) (request, error) {
	bound, err := svc.Model.bindRequest(op, input)
	if err != nil {
		return request{}, err
	}
	req := bound.request
	inputShape, err := svc.Model.shape(op.InputID())
	if err != nil {
		return request{}, err
	}
	switch {
	case bound.payload != nil:
		target, err := svc.Model.shape(bound.payload.member.Target)
		if err != nil {
			return request{}, err
		}
		if target.Type == "structure" || target.Type == "union" || target.Type == "document" {
			body, err := svc.Model.encodeJSON(bound.payload.member.Target, bound.payload.member.Traits, bound.payload.value, true)
			if err != nil {
				return request{}, fmt.Errorf("%s: %w", bound.payload.name, err)
			}
			req.Body, err = json.Marshal(body)
			if err != nil {
				return request{}, err
			}
			req.Header.Set("Content-Type", "application/json")
		} else {
			str, ok := bound.payload.value.(string)
			if !ok {
				return request{}, fmt.Errorf("%s must be a string", bound.payload.name)
			}
			req.Body = []byte(str)
		}
	case hasDocumentMembers(inputShape):
		body := map[string]any{}
		for name, value := range bound.unbound {
			mem := inputShape.Members[name]
			encoded, err := svc.Model.encodeJSON(mem.Target, mem.Traits, value, true)
			if err != nil {
				return request{}, fmt.Errorf("%s: %w", name, err)
			}
			body[wireName(name, mem, true)] = encoded
		}
		req.Body, err = json.Marshal(body)
		if err != nil {
			return request{}, err
		}
		req.Header.Set("Content-Type", "application/json")
	}
	return req, nil
}

func (p restJSON) decode(svc *Service, op *Operation, resp response) (any, error) {
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
	if len(resp.Body) == 0 {
		return out, nil
	}
	if name, mem := payloadMember(output); mem != nil {
		target, err := svc.Model.shape(mem.Target)
		if err != nil {
			return nil, err
		}
		if target.Type == "structure" || target.Type == "union" || target.Type == "document" {
			var v any
			err := json.Unmarshal(resp.Body, &v)
			if err != nil {
				return nil, fmt.Errorf("decode response: %w", err)
			}
			out[name] = svc.Model.decodeJSON(mem.Target, mem.Traits, v, true)
		} else {
			out[name] = string(resp.Body)
		}
		return out, nil
	}
	var body map[string]any
	err = json.Unmarshal(resp.Body, &body)
	if err != nil {
		return nil, fmt.Errorf("decode response: %w", err)
	}
	for name, mem := range output.Members {
		if httpBound(mem) {
			continue
		}
		v, ok := body[wireName(name, mem, true)]
		if !ok {
			continue
		}
		out[name] = svc.Model.decodeJSON(mem.Target, mem.Traits, v, true)
	}
	return out, nil
}

func (p restJSON) decodeError(resp response) apiError {
	var body map[string]any
	_ = json.Unmarshal(resp.Body, &body)
	code := resp.Header.Get("X-Amzn-Errortype")
	if code == "" {
		code = firstString(body, "code", "__type", "Code")
	}
	msg := firstString(body, "message", "Message", "errorMessage")
	if msg == "" {
		msg = strings.TrimSpace(string(resp.Body))
	}
	if msg == "" {
		msg = http.StatusText(resp.Status)
	}
	return apiError{Code: sanitizeErrorCode(code), Message: msg}
}

func hasDocumentMembers(s *Shape) bool {
	for _, mem := range s.Members {
		if httpBound(mem) {
			continue
		}
		if mem.Traits.Has("smithy.api#httpLabel") || mem.Traits.Has("smithy.api#httpQuery") || mem.Traits.Has("smithy.api#httpQueryParams") {
			continue
		}
		return true
	}
	return false
}
