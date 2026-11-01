package aws

import (
	"encoding/json"
	"fmt"
	"strings"
)

type Model struct {
	Smithy string            `json:"smithy"`
	Shapes map[string]*Shape `json:"shapes"`
}

type Shape struct {
	Type       string             `json:"type"`
	Version    string             `json:"version,omitempty"`
	Members    map[string]*Member `json:"members,omitempty"`
	Member     *Member            `json:"member,omitempty"`
	Key        *Member            `json:"key,omitempty"`
	Value      *Member            `json:"value,omitempty"`
	Input      *Member            `json:"input,omitempty"`
	Output     *Member            `json:"output,omitempty"`
	Errors     []*Member          `json:"errors,omitempty"`
	Operations []*Member          `json:"operations,omitempty"`
	Traits     Traits             `json:"traits,omitempty"`
}

type Member struct {
	Target string `json:"target"`
	Traits Traits `json:"traits,omitempty"`
}

type Traits map[string]json.RawMessage

func (t Traits) Has(id string) bool {
	_, ok := t[id]
	return ok
}

func (t Traits) Decode(id string, v any) (bool, error) {
	raw, ok := t[id]
	if !ok {
		return false, nil
	}
	err := json.Unmarshal(raw, v)
	if err != nil {
		return true, fmt.Errorf("trait %s: %w", id, err)
	}
	return true, nil
}

func (t Traits) String(id string) string {
	var s string
	ok, err := t.Decode(id, &s)
	if !ok || err != nil {
		return ""
	}
	return s
}

const unitShape = "smithy.api#Unit"

var preludeTypes = map[string]string{
	"smithy.api#String":           "string",
	"smithy.api#Blob":             "blob",
	"smithy.api#Boolean":          "boolean",
	"smithy.api#PrimitiveBoolean": "boolean",
	"smithy.api#Byte":             "byte",
	"smithy.api#PrimitiveByte":    "byte",
	"smithy.api#Short":            "short",
	"smithy.api#PrimitiveShort":   "short",
	"smithy.api#Integer":          "integer",
	"smithy.api#PrimitiveInteger": "integer",
	"smithy.api#Long":             "long",
	"smithy.api#PrimitiveLong":    "long",
	"smithy.api#Float":            "float",
	"smithy.api#PrimitiveFloat":   "float",
	"smithy.api#Double":           "double",
	"smithy.api#PrimitiveDouble":  "double",
	"smithy.api#BigInteger":       "bigInteger",
	"smithy.api#BigDecimal":       "bigDecimal",
	"smithy.api#Timestamp":        "timestamp",
	"smithy.api#Document":         "document",
	unitShape:                     "structure",
}

func (m *Model) shape(id string) (*Shape, error) {
	if s, ok := m.Shapes[id]; ok {
		return s, nil
	}
	if t, ok := preludeTypes[id]; ok {
		return &Shape{Type: t}, nil
	}
	return nil, fmt.Errorf("unknown shape %s", id)
}

func localName(id string) string {
	_, name, ok := strings.Cut(id, "#")
	if !ok {
		return id
	}
	return name
}

const redacted = "<redacted>"

func sensitive(member Traits, shape Traits) bool {
	return member.Has("smithy.api#sensitive") || shape.Has("smithy.api#sensitive")
}
