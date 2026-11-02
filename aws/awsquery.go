package aws

import (
	"fmt"
	"net/http"
	"net/url"
	"sort"
	"strings"
)

type awsQuery struct{}

func (p awsQuery) encode(svc *Service, op *Operation, input map[string]any) (request, error) {
	values := url.Values{}
	values.Set("Action", op.Name)
	values.Set("Version", svc.Version)
	err := svc.Model.encodeAWSQuery(op.InputID(), nil, "", input, values)
	if err != nil {
		return request{}, err
	}
	h := http.Header{}
	h.Set("Content-Type", "application/x-www-form-urlencoded; charset=utf-8")
	return request{Method: http.MethodPost, Path: "/", Header: h, Body: []byte(values.Encode())}, nil
}

func (p awsQuery) decode(svc *Service, op *Operation, resp response) (any, error) {
	if len(resp.Body) == 0 {
		return map[string]any{}, nil
	}
	root, err := parseXML(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("decode response: %w", err)
	}
	result := root.child(op.Name + "Result")
	if result == nil {
		return map[string]any{}, nil
	}
	return svc.Model.decodeXML(op.OutputID(), nil, result), nil
}

func (p awsQuery) decodeError(resp response) apiError {
	root, err := parseXML(resp.Body)
	if err != nil {
		msg := strings.TrimSpace(string(resp.Body))
		if msg == "" {
			msg = http.StatusText(resp.Status)
		}
		return apiError{Message: msg}
	}
	e := root
	if first := root.child("Error"); first != nil {
		e = first
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

func queryKey(prefix string, name string) string {
	if prefix == "" {
		return name
	}
	return prefix + "." + name
}

func (m *Model) encodeAWSQuery(id string, memberTraits Traits, key string, v any, out url.Values) error {
	if v == nil {
		return nil
	}
	s, err := m.shape(id)
	if err != nil {
		return err
	}
	flattened := memberTraits.Has("smithy.api#xmlFlattened")
	switch s.Type {
	case "structure", "union":
		obj, ok := v.(map[string]any)
		if !ok {
			return fmt.Errorf("%s must be an object", localName(id))
		}
		for k, mv := range obj {
			if mv == nil {
				continue
			}
			mem, ok := s.Members[k]
			if !ok {
				return fmt.Errorf("%s has no member %s", localName(id), k)
			}
			err := m.encodeAWSQuery(mem.Target, mem.Traits, queryKey(key, xmlMemberName(k, mem)), mv, out)
			if err != nil {
				return fmt.Errorf("%s: %w", k, err)
			}
		}
		return nil
	case "list", "set":
		arr, ok := v.([]any)
		if !ok {
			return fmt.Errorf("%s must be an array", localName(id))
		}
		if len(arr) == 0 {
			out.Set(key, "")
			return nil
		}
		prefix := key
		if !flattened {
			prefix = queryKey(key, xmlMemberName("member", s.Member))
		}
		for i, e := range arr {
			err := m.encodeAWSQuery(s.Member.Target, s.Member.Traits, fmt.Sprintf("%s.%d", prefix, i+1), e, out)
			if err != nil {
				return fmt.Errorf("[%d]: %w", i, err)
			}
		}
		return nil
	case "map":
		obj, ok := v.(map[string]any)
		if !ok {
			return fmt.Errorf("%s must be an object", localName(id))
		}
		prefix := key
		if !flattened {
			prefix = queryKey(key, "entry")
		}
		keyName := xmlMemberName("key", s.Key)
		valueName := xmlMemberName("value", s.Value)
		for i, k := range sortedKeys(obj) {
			entry := fmt.Sprintf("%s.%d", prefix, i+1)
			out.Set(queryKey(entry, keyName), k)
			err := m.encodeAWSQuery(s.Value.Target, s.Value.Traits, queryKey(entry, valueName), obj[k], out)
			if err != nil {
				return fmt.Errorf("%s: %w", k, err)
			}
		}
		return nil
	default:
		str, err := m.queryScalar(id, memberTraits, s, v)
		if err != nil {
			return err
		}
		out.Set(key, str)
		return nil
	}
}

func sortedKeys(obj map[string]any) []string {
	keys := make([]string, 0, len(obj))
	for k := range obj {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	return keys
}
