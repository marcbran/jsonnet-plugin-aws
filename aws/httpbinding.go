package aws

import (
	"fmt"
	"net/http"
	"net/url"
	"sort"
	"strconv"
	"strings"
)

type httpTrait struct {
	Method string `json:"method"`
	URI    string `json:"uri"`
	Code   int    `json:"code"`
}

type boundRequest struct {
	request
	unbound map[string]any
	payload *boundPayload
}

type boundPayload struct {
	name   string
	member *Member
	value  any
}

func (op *Operation) http() (httpTrait, error) {
	var t httpTrait
	ok, err := op.Shape.Traits.Decode("smithy.api#http", &t)
	if err != nil {
		return t, err
	}
	if !ok {
		return t, fmt.Errorf("%s has no http binding", op.Name)
	}
	return t, nil
}

func (m *Model) bindRequest(op *Operation, input map[string]any) (boundRequest, error) {
	binding, err := op.http()
	if err != nil {
		return boundRequest{}, err
	}
	pathTemplate, literalQuery, _ := strings.Cut(binding.URI, "?")
	query := url.Values{}
	for _, part := range strings.Split(literalQuery, "&") {
		if part == "" {
			continue
		}
		k, v, _ := strings.Cut(part, "=")
		query.Set(k, v)
	}
	header := http.Header{}
	out := boundRequest{
		request: request{Method: binding.Method, Query: query, Header: header},
		unbound: map[string]any{},
	}
	inputShape, err := m.shape(op.InputID())
	if err != nil {
		return boundRequest{}, err
	}
	for k := range input {
		if _, ok := inputShape.Members[k]; !ok && input[k] != nil {
			return boundRequest{}, fmt.Errorf("%s has no member %s", localName(op.InputID()), k)
		}
	}
	path := pathTemplate
	for _, name := range sortedMemberNames(inputShape.Members) {
		mem := inputShape.Members[name]
		value, present := input[name]
		if mem.Traits.Has("smithy.api#httpLabel") {
			if !present || value == nil {
				return boundRequest{}, fmt.Errorf("%s is required", name)
			}
			s, err := m.httpString(mem, value, "date-time")
			if err != nil {
				return boundRequest{}, fmt.Errorf("%s: %w", name, err)
			}
			greedy := "{" + name + "+}"
			if strings.Contains(path, greedy) {
				segments := strings.Split(s, "/")
				for i, segment := range segments {
					segments[i] = escapeLabel(segment)
				}
				path = strings.ReplaceAll(path, greedy, strings.Join(segments, "/"))
			} else {
				path = strings.ReplaceAll(path, "{"+name+"}", escapeLabel(s))
			}
			continue
		}
		if !present || value == nil {
			continue
		}
		switch {
		case mem.Traits.Has("smithy.api#httpQuery"):
			key := mem.Traits.String("smithy.api#httpQuery")
			values, err := m.httpStrings(mem, value, "date-time")
			if err != nil {
				return boundRequest{}, fmt.Errorf("%s: %w", name, err)
			}
			for _, v := range values {
				query.Add(key, v)
			}
		case mem.Traits.Has("smithy.api#httpQueryParams"):
			obj, ok := value.(map[string]any)
			if !ok {
				return boundRequest{}, fmt.Errorf("%s must be an object", name)
			}
			for k, v := range obj {
				query.Add(k, fmt.Sprint(v))
			}
		case mem.Traits.Has("smithy.api#httpHeader"):
			values, err := m.httpStrings(mem, value, "http-date")
			if err != nil {
				return boundRequest{}, fmt.Errorf("%s: %w", name, err)
			}
			header.Set(mem.Traits.String("smithy.api#httpHeader"), strings.Join(values, ","))
		case mem.Traits.Has("smithy.api#httpPrefixHeaders"):
			obj, ok := value.(map[string]any)
			if !ok {
				return boundRequest{}, fmt.Errorf("%s must be an object", name)
			}
			prefix := mem.Traits.String("smithy.api#httpPrefixHeaders")
			for k, v := range obj {
				header.Set(prefix+k, fmt.Sprint(v))
			}
		case mem.Traits.Has("smithy.api#httpPayload"):
			out.payload = &boundPayload{name: name, member: mem, value: value}
		default:
			out.unbound[name] = value
		}
	}
	out.Path = path
	return out, nil
}

func escapeLabel(s string) string {
	var b strings.Builder
	for i := 0; i < len(s); i++ {
		c := s[i]
		if c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z' || c >= '0' && c <= '9' || c == '-' || c == '.' || c == '_' || c == '~' {
			b.WriteByte(c)
			continue
		}
		fmt.Fprintf(&b, "%%%02X", c)
	}
	return b.String()
}

func sortedMemberNames(members map[string]*Member) []string {
	names := make([]string, 0, len(members))
	for name := range members {
		names = append(names, name)
	}
	sort.Strings(names)
	return names
}

func (m *Model) httpStrings(mem *Member, value any, timestampDefault string) ([]string, error) {
	s, err := m.shape(mem.Target)
	if err != nil {
		return nil, err
	}
	if s.Type == "list" || s.Type == "set" {
		arr, ok := value.([]any)
		if !ok {
			return nil, fmt.Errorf("must be an array")
		}
		out := make([]string, 0, len(arr))
		for _, e := range arr {
			v, err := m.httpString(s.Member, e, timestampDefault)
			if err != nil {
				return nil, err
			}
			out = append(out, v)
		}
		return out, nil
	}
	v, err := m.httpString(mem, value, timestampDefault)
	if err != nil {
		return nil, err
	}
	return []string{v}, nil
}

func (m *Model) httpString(mem *Member, value any, timestampDefault string) (string, error) {
	s, err := m.shape(mem.Target)
	if err != nil {
		return "", err
	}
	switch s.Type {
	case "timestamp":
		t, err := parseTimestamp(value)
		if err != nil {
			return "", err
		}
		return fmt.Sprint(formatTimestamp(t, timestampFormat(mem.Traits, s.Traits, timestampDefault))), nil
	case "boolean":
		b, ok := value.(bool)
		if !ok {
			return "", fmt.Errorf("must be a boolean")
		}
		return strconv.FormatBool(b), nil
	case "byte", "short", "integer", "intEnum", "long", "float", "double", "bigInteger", "bigDecimal":
		f, ok := value.(float64)
		if !ok {
			return "", fmt.Errorf("must be a number")
		}
		return strconv.FormatFloat(f, 'f', -1, 64), nil
	default:
		str, ok := value.(string)
		if !ok {
			return "", fmt.Errorf("must be a string")
		}
		return str, nil
	}
}

func (m *Model) decodeHTTPHeaders(output *Shape, header http.Header, out map[string]any) {
	for name, mem := range output.Members {
		switch {
		case mem.Traits.Has("smithy.api#httpHeader"):
			raw := header.Get(mem.Traits.String("smithy.api#httpHeader"))
			if raw == "" {
				continue
			}
			out[name] = m.decodeHeaderValue(mem, raw)
		case mem.Traits.Has("smithy.api#httpPrefixHeaders"):
			prefix := strings.ToLower(mem.Traits.String("smithy.api#httpPrefixHeaders"))
			values := map[string]any{}
			for k, vs := range header {
				if strings.HasPrefix(strings.ToLower(k), prefix) && len(vs) > 0 {
					values[strings.ToLower(k)[len(prefix):]] = vs[0]
				}
			}
			if len(values) > 0 {
				out[name] = values
			}
		}
	}
}

func (m *Model) decodeHeaderValue(mem *Member, raw string) any {
	s, err := m.shape(mem.Target)
	if err != nil {
		return raw
	}
	if sensitive(mem.Traits, s.Traits) {
		return redacted
	}
	switch s.Type {
	case "list", "set":
		parts := strings.Split(raw, ",")
		out := make([]any, 0, len(parts))
		for _, p := range parts {
			out = append(out, m.decodeHeaderValue(s.Member, strings.TrimSpace(p)))
		}
		return out
	case "boolean":
		return raw == "true"
	case "byte", "short", "integer", "intEnum", "long", "float", "double", "bigInteger", "bigDecimal":
		f, err := strconv.ParseFloat(raw, 64)
		if err != nil {
			return raw
		}
		return f
	case "timestamp":
		var v any = raw
		if f, err := strconv.ParseFloat(raw, 64); err == nil {
			v = f
		}
		t, err := parseTimestamp(v)
		if err != nil {
			return raw
		}
		return formatTimestamp(t, "date-time")
	default:
		return raw
	}
}

func (op *Operation) streamingOutput(m *Model) bool {
	output, err := m.shape(op.OutputID())
	if err != nil {
		return false
	}
	for _, mem := range output.Members {
		if !mem.Traits.Has("smithy.api#httpPayload") {
			continue
		}
		target, err := m.shape(mem.Target)
		if err == nil && target.Traits.Has("smithy.api#streaming") {
			return true
		}
	}
	return false
}
