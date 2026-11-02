package aws

import (
	"fmt"
)

func (m *Model) encodeJSON(id string, memberTraits Traits, v any, useJSONName bool) (any, error) {
	if v == nil {
		return nil, nil
	}
	s, err := m.shape(id)
	if err != nil {
		return nil, err
	}
	switch s.Type {
	case "structure", "union":
		obj, ok := v.(map[string]any)
		if !ok {
			return nil, fmt.Errorf("%s must be an object", localName(id))
		}
		out := make(map[string]any, len(obj))
		for k, mv := range obj {
			if mv == nil {
				continue
			}
			mem, ok := s.Members[k]
			if !ok {
				return nil, fmt.Errorf("%s has no member %s", localName(id), k)
			}
			ev, err := m.encodeJSON(mem.Target, mem.Traits, mv, useJSONName)
			if err != nil {
				return nil, fmt.Errorf("%s: %w", k, err)
			}
			out[wireName(k, mem, useJSONName)] = ev
		}
		return out, nil
	case "list", "set":
		arr, ok := v.([]any)
		if !ok {
			return nil, fmt.Errorf("%s must be an array", localName(id))
		}
		out := make([]any, 0, len(arr))
		for i, e := range arr {
			ev, err := m.encodeJSON(s.Member.Target, s.Member.Traits, e, useJSONName)
			if err != nil {
				return nil, fmt.Errorf("[%d]: %w", i, err)
			}
			out = append(out, ev)
		}
		return out, nil
	case "map":
		obj, ok := v.(map[string]any)
		if !ok {
			return nil, fmt.Errorf("%s must be an object", localName(id))
		}
		out := make(map[string]any, len(obj))
		for k, mv := range obj {
			ev, err := m.encodeJSON(s.Value.Target, s.Value.Traits, mv, useJSONName)
			if err != nil {
				return nil, fmt.Errorf("%s: %w", k, err)
			}
			out[k] = ev
		}
		return out, nil
	case "timestamp":
		t, err := parseTimestamp(v)
		if err != nil {
			return nil, err
		}
		return formatTimestamp(t, timestampFormat(memberTraits, s.Traits, "epoch-seconds")), nil
	default:
		return v, nil
	}
}

func (m *Model) decodeJSON(id string, memberTraits Traits, v any, useJSONName bool) any {
	if v == nil {
		return nil
	}
	s, err := m.shape(id)
	if err != nil {
		return v
	}
	if sensitive(memberTraits, s.Traits) {
		return redacted
	}
	switch s.Type {
	case "structure", "union":
		obj, ok := v.(map[string]any)
		if !ok {
			return v
		}
		names := make(map[string]string, len(s.Members))
		for name, mem := range s.Members {
			names[wireName(name, mem, useJSONName)] = name
		}
		out := make(map[string]any, len(obj))
		for k, mv := range obj {
			name, ok := names[k]
			if !ok {
				out[k] = mv
				continue
			}
			mem := s.Members[name]
			out[name] = m.decodeJSON(mem.Target, mem.Traits, mv, useJSONName)
		}
		return out
	case "list", "set":
		arr, ok := v.([]any)
		if !ok {
			return v
		}
		out := make([]any, 0, len(arr))
		for _, e := range arr {
			out = append(out, m.decodeJSON(s.Member.Target, s.Member.Traits, e, useJSONName))
		}
		return out
	case "map":
		obj, ok := v.(map[string]any)
		if !ok {
			return v
		}
		out := make(map[string]any, len(obj))
		for k, mv := range obj {
			out[k] = m.decodeJSON(s.Value.Target, s.Value.Traits, mv, useJSONName)
		}
		return out
	case "timestamp":
		t, err := parseTimestamp(v)
		if err != nil {
			return v
		}
		return formatTimestamp(t, "date-time")
	default:
		return v
	}
}

func wireName(name string, mem *Member, useJSONName bool) string {
	if useJSONName {
		if n := mem.Traits.String("smithy.api#jsonName"); n != "" {
			return n
		}
	}
	return name
}
