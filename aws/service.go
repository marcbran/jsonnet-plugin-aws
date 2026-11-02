package aws

import (
	"encoding/json"
	"fmt"
	"slices"
	"strings"
	"sync"
)

type Definition struct {
	Model            []byte
	DeniedOperations []string
}

type Service struct {
	ID             string
	Key            string
	Version        string
	SigningName    string
	EndpointPrefix string
	Model          *Model
	protocol       protocol
	operations     map[string]string
	denied         []string
}

type Operation struct {
	ID    string
	Name  string
	Shape *Shape
}

var readPrefixes = []string{"Describe", "List", "Get", "Head", "BatchGet"}

func (s *Service) Readable(op *Operation) bool {
	return op.Readonly() && !slices.Contains(s.denied, op.Name) && !op.streamingOutput(s.Model)
}

func (o *Operation) Readonly() bool {
	if o.Shape.Traits.Has("smithy.api#readonly") {
		return true
	}
	return slices.ContainsFunc(readPrefixes, func(p string) bool {
		return strings.HasPrefix(o.Name, p)
	})
}

func (o *Operation) InputID() string {
	if o.Shape.Input == nil {
		return unitShape
	}
	return o.Shape.Input.Target
}

func (o *Operation) OutputID() string {
	if o.Shape.Output == nil {
		return unitShape
	}
	return o.Shape.Output.Target
}

func (s *Service) Operation(name string) (*Operation, error) {
	id, ok := s.operations[name]
	if !ok {
		return nil, fmt.Errorf("%s has no operation %s", s.Key, name)
	}
	shape, err := s.Model.shape(id)
	if err != nil {
		return nil, err
	}
	return &Operation{ID: id, Name: name, Shape: shape}, nil
}

func (s *Service) Name() string {
	return localName(s.ID)
}

func LoadService(def Definition) (*Service, error) {
	var m Model
	err := json.Unmarshal(def.Model, &m)
	if err != nil {
		return nil, fmt.Errorf("parse model: %w", err)
	}
	var id string
	var shape *Shape
	for k, v := range m.Shapes {
		if v.Type != "service" {
			continue
		}
		if shape != nil {
			return nil, fmt.Errorf("model has more than one service: %s, %s", id, k)
		}
		id, shape = k, v
	}
	if shape == nil {
		return nil, fmt.Errorf("model has no service")
	}
	var meta struct {
		SdkID          string `json:"sdkId"`
		EndpointPrefix string `json:"endpointPrefix"`
	}
	_, err = shape.Traits.Decode("aws.api#service", &meta)
	if err != nil {
		return nil, err
	}
	var sigv4 struct {
		Name string `json:"name"`
	}
	_, err = shape.Traits.Decode("aws.auth#sigv4", &sigv4)
	if err != nil {
		return nil, err
	}
	proto, err := protocolFor(shape.Traits)
	if err != nil {
		return nil, fmt.Errorf("%s: %w", id, err)
	}
	svc := &Service{
		ID:             id,
		Key:            serviceKey(meta.SdkID),
		Version:        shape.Version,
		SigningName:    sigv4.Name,
		EndpointPrefix: meta.EndpointPrefix,
		Model:          &m,
		protocol:       proto,
		operations:     map[string]string{},
		denied:         def.DeniedOperations,
	}
	for _, op := range shape.Operations {
		svc.operations[localName(op.Target)] = op.Target
	}
	return svc, nil
}

func serviceKey(sdkID string) string {
	return strings.ToLower(strings.ReplaceAll(sdkID, " ", "-"))
}

type registry struct {
	definitions []Definition
	once        sync.Once
	services    map[string]*Service
	err         error
}

func (r *registry) service(key string) (*Service, error) {
	r.once.Do(r.load)
	if r.err != nil {
		return nil, r.err
	}
	svc, ok := r.services[key]
	if !ok {
		return nil, fmt.Errorf("unknown service %s", key)
	}
	return svc, nil
}

func (r *registry) load() {
	r.services = map[string]*Service{}
	for _, def := range r.definitions {
		svc, err := LoadService(def)
		if err != nil {
			r.err = err
			return
		}
		r.services[svc.Key] = svc
	}
}
