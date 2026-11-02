package aws

import (
	"bytes"
	"encoding/xml"
	"errors"
	"io"
	"strconv"
	"strings"
)

type xmlNode struct {
	Name     string
	Text     string
	Attrs    map[string]string
	Children []*xmlNode
}

func (n *xmlNode) child(name string) *xmlNode {
	for _, c := range n.Children {
		if c.Name == name {
			return c
		}
	}
	return nil
}

func (n *xmlNode) children(name string) []*xmlNode {
	var out []*xmlNode
	for _, c := range n.Children {
		if c.Name == name {
			out = append(out, c)
		}
	}
	return out
}

func parseXML(body []byte) (*xmlNode, error) {
	decoder := xml.NewDecoder(bytes.NewReader(body))
	var stack []*xmlNode
	var root *xmlNode
	for {
		token, err := decoder.Token()
		if errors.Is(err, io.EOF) {
			break
		}
		if err != nil {
			return nil, err
		}
		switch t := token.(type) {
		case xml.StartElement:
			node := &xmlNode{Name: t.Name.Local, Attrs: map[string]string{}}
			for _, attr := range t.Attr {
				node.Attrs[attr.Name.Local] = attr.Value
			}
			if len(stack) > 0 {
				parent := stack[len(stack)-1]
				parent.Children = append(parent.Children, node)
			} else {
				root = node
			}
			stack = append(stack, node)
		case xml.EndElement:
			stack = stack[:len(stack)-1]
		case xml.CharData:
			if len(stack) > 0 {
				stack[len(stack)-1].Text += string(t)
			}
		}
	}
	if root == nil {
		return nil, errors.New("empty XML document")
	}
	return root, nil
}

func (m *Model) decodeFlattened(mem *Member, nodes []*xmlNode) (any, bool) {
	if len(nodes) == 0 {
		return nil, false
	}
	s, err := m.shape(mem.Target)
	if err != nil {
		return nil, false
	}
	switch s.Type {
	case "list", "set":
		out := make([]any, 0, len(nodes))
		for _, node := range nodes {
			out = append(out, m.decodeXML(s.Member.Target, s.Member.Traits, node))
		}
		return out, true
	case "map":
		out := map[string]any{}
		keyName := xmlMemberName("key", s.Key)
		valueName := xmlMemberName("value", s.Value)
		for _, entry := range nodes {
			k := entry.child(keyName)
			v := entry.child(valueName)
			if k == nil || v == nil {
				continue
			}
			out[strings.TrimSpace(k.Text)] = m.decodeXML(s.Value.Target, s.Value.Traits, v)
		}
		return out, true
	default:
		return m.decodeXML(mem.Target, mem.Traits, nodes[0]), true
	}
}

func xmlMemberName(name string, member *Member) string {
	if n := member.Traits.String("smithy.api#xmlName"); n != "" {
		return n
	}
	return name
}

func xmlLocalName(name string) string {
	_, local, ok := strings.Cut(name, ":")
	if !ok {
		return name
	}
	return local
}

func (m *Model) decodeXML(id string, memberTraits Traits, n *xmlNode) any {
	s, err := m.shape(id)
	if err != nil {
		return strings.TrimSpace(n.Text)
	}
	if sensitive(memberTraits, s.Traits) {
		return redacted
	}
	text := strings.TrimSpace(n.Text)
	switch s.Type {
	case "structure", "union":
		out := map[string]any{}
		for name, mem := range s.Members {
			elementName := xmlLocalName(xmlMemberName(name, mem))
			if mem.Traits.Has("smithy.api#xmlAttribute") {
				if v, ok := n.Attrs[elementName]; ok {
					out[name] = m.decodeXML(mem.Target, mem.Traits, &xmlNode{Text: v})
				}
				continue
			}
			if mem.Traits.Has("smithy.api#xmlFlattened") {
				if v, ok := m.decodeFlattened(mem, n.children(elementName)); ok {
					out[name] = v
				}
				continue
			}
			c := n.child(elementName)
			if c == nil {
				continue
			}
			out[name] = m.decodeXML(mem.Target, mem.Traits, c)
		}
		return out
	case "list", "set":
		items := n.children(xmlMemberName("member", s.Member))
		out := make([]any, 0, len(items))
		for _, item := range items {
			out = append(out, m.decodeXML(s.Member.Target, s.Member.Traits, item))
		}
		return out
	case "map":
		out := map[string]any{}
		keyName := xmlMemberName("key", s.Key)
		valueName := xmlMemberName("value", s.Value)
		for _, entry := range n.children("entry") {
			k := entry.child(keyName)
			v := entry.child(valueName)
			if k == nil || v == nil {
				continue
			}
			out[strings.TrimSpace(k.Text)] = m.decodeXML(s.Value.Target, s.Value.Traits, v)
		}
		return out
	case "boolean":
		return text == "true"
	case "byte", "short", "integer", "intEnum", "long", "float", "double", "bigInteger", "bigDecimal":
		f, err := strconv.ParseFloat(text, 64)
		if err != nil {
			return text
		}
		return f
	case "timestamp":
		var v any = text
		if f, err := strconv.ParseFloat(text, 64); err == nil {
			v = f
		}
		t, err := parseTimestamp(v)
		if err != nil {
			return text
		}
		return formatTimestamp(t, "date-time")
	default:
		return text
	}
}
