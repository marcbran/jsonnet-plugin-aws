package aws

import (
	"encoding/base64"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"strings"
)

type ec2Query struct{}

func (p ec2Query) encode(svc *Service, op *Operation, input map[string]any) (request, error) {
	values := url.Values{}
	values.Set("Action", op.Name)
	values.Set("Version", svc.Version)
	err := svc.Model.encodeEC2Query(op.InputID(), nil, "", input, values)
	if err != nil {
		return request{}, err
	}
	h := http.Header{}
	h.Set("Content-Type", "application/x-www-form-urlencoded; charset=utf-8")
	return request{Method: http.MethodPost, Path: "/", Header: h, Body: []byte(values.Encode())}, nil
}

func (p ec2Query) decode(svc *Service, op *Operation, resp response) (any, error) {
	if len(resp.Body) == 0 {
		return map[string]any{}, nil
	}
	root, err := parseXML(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("decode response: %w", err)
	}
	return svc.Model.decodeXML(op.OutputID(), nil, root), nil
}

func (p ec2Query) decodeError(resp response) apiError {
	root, err := parseXML(resp.Body)
	if err != nil {
		return apiError{Message: strings.TrimSpace(string(resp.Body))}
	}
	e := root
	if errs := root.child("Errors"); errs != nil {
		if first := errs.child("Error"); first != nil {
			e = first
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

func ec2QueryMemberName(name string, member *Member) string {
	if n := member.Traits.String("aws.protocols#ec2QueryName"); n != "" {
		return n
	}
	if n := member.Traits.String("smithy.api#xmlName"); n != "" {
		return strings.ToUpper(n[:1]) + n[1:]
	}
	return strings.ToUpper(name[:1]) + name[1:]
}

func (m *Model) encodeEC2Query(id string, memberTraits Traits, key string, v any, out url.Values) error {
	if v == nil {
		return nil
	}
	s, err := m.shape(id)
	if err != nil {
		return err
	}
	prefix := key
	if prefix != "" {
		prefix += "."
	}
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
			err := m.encodeEC2Query(mem.Target, mem.Traits, prefix+ec2QueryMemberName(k, mem), mv, out)
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
		for i, e := range arr {
			err := m.encodeEC2Query(s.Member.Target, s.Member.Traits, fmt.Sprintf("%s.%d", key, i+1), e, out)
			if err != nil {
				return fmt.Errorf("[%d]: %w", i, err)
			}
		}
		return nil
	case "map":
		return fmt.Errorf("%s: maps are not supported in ec2Query requests", localName(id))
	default:
		str, err := m.queryScalar(id, memberTraits, s, v)
		if err != nil {
			return err
		}
		out.Set(key, str)
		return nil
	}
}

func (m *Model) queryScalar(id string, memberTraits Traits, s *Shape, v any) (string, error) {
	switch s.Type {
	case "timestamp":
		t, err := parseTimestamp(v)
		if err != nil {
			return "", err
		}
		return fmt.Sprint(formatTimestamp(t, timestampFormat(memberTraits, s.Traits, "date-time"))), nil
	case "boolean":
		b, ok := v.(bool)
		if !ok {
			return "", fmt.Errorf("%s must be a boolean", localName(id))
		}
		return strconv.FormatBool(b), nil
	case "byte", "short", "integer", "intEnum", "long", "float", "double", "bigInteger", "bigDecimal":
		f, ok := v.(float64)
		if !ok {
			return "", fmt.Errorf("%s must be a number", localName(id))
		}
		return strconv.FormatFloat(f, 'f', -1, 64), nil
	case "blob":
		str, ok := v.(string)
		if !ok {
			return "", fmt.Errorf("%s must be a base64 string", localName(id))
		}
		_, err := base64.StdEncoding.DecodeString(str)
		if err != nil {
			return "", fmt.Errorf("%s must be a base64 string", localName(id))
		}
		return str, nil
	default:
		str, ok := v.(string)
		if !ok {
			return "", fmt.Errorf("%s must be a string", localName(id))
		}
		return str, nil
	}
}
