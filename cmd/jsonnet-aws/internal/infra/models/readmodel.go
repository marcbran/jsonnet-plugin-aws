package models

import (
	"strings"

	"github.com/marcbran/jsonnet-plugin-aws/aws"
)

var droppedTraitPrefixes = []string{
	"smithy.rules#",
	"smithy.test#",
	"smithy.waiters#",
	"smithy.api#examples",
}

func readModel(s *aws.Service) *aws.Model {
	out := &aws.Model{Smithy: s.Model.Smithy, Shapes: map[string]*aws.Shape{}}
	service := s.Model.Shapes[s.ID]
	slim := slimShape(service)
	slim.Operations = nil
	for _, ref := range service.Operations {
		op, err := s.Operation(localName(ref.Target))
		if err != nil || !s.Readable(op) {
			continue
		}
		slim.Operations = append(slim.Operations, ref)
		collect(s.Model, ref.Target, out.Shapes)
	}
	out.Shapes[s.ID] = slim
	return out
}

func collect(m *aws.Model, id string, into map[string]*aws.Shape) {
	if _, ok := into[id]; ok {
		return
	}
	shape, ok := m.Shapes[id]
	if !ok {
		return
	}
	slim := slimShape(shape)
	slim.Errors = nil
	into[id] = slim
	for _, ref := range shapeRefs(slim) {
		collect(m, ref.Target, into)
	}
}

func shapeRefs(s *aws.Shape) []*aws.Member {
	var refs []*aws.Member
	for _, ref := range []*aws.Member{s.Member, s.Key, s.Value, s.Input, s.Output} {
		if ref != nil {
			refs = append(refs, ref)
		}
	}
	for _, ref := range s.Members {
		refs = append(refs, ref)
	}
	return refs
}

func slimShape(s *aws.Shape) *aws.Shape {
	c := *s
	c.Traits = aws.Traits{}
	for id, v := range s.Traits {
		if !droppedTrait(id) {
			c.Traits[id] = v
		}
	}
	if len(c.Traits) == 0 {
		c.Traits = nil
	}
	return &c
}

func droppedTrait(id string) bool {
	for _, p := range droppedTraitPrefixes {
		if strings.HasPrefix(id, p) {
			return true
		}
	}
	return false
}

func localName(id string) string {
	_, name, ok := strings.Cut(id, "#")
	if !ok {
		return id
	}
	return name
}
