package models

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/marcbran/jsonnet-plugin-aws/aws"
)

type Loader struct {
	services []aws.Definition
}

func NewLoader(services ...aws.Definition) *Loader {
	return &Loader{services: services}
}

func (l *Loader) LoadModel(ctx context.Context, service string) (string, error) {
	for _, def := range l.services {
		svc, err := aws.LoadService(def)
		if err != nil {
			return "", err
		}
		if svc.Key != service {
			continue
		}
		raw, err := json.Marshal(readModel(svc))
		if err != nil {
			return "", err
		}
		return string(raw), nil
	}
	return "", fmt.Errorf("unknown service %s", service)
}
