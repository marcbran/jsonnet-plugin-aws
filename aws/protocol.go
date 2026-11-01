package aws

import (
	"fmt"
	"net/http"
	"net/url"
)

type request struct {
	Method string
	Path   string
	Query  url.Values
	Header http.Header
	Body   []byte
}

type response struct {
	Status int
	Header http.Header
	Body   []byte
}

type apiError struct {
	Code    string
	Message string
}

type protocol interface {
	encode(svc *Service, op *Operation, input map[string]any) (request, error)
	decode(svc *Service, op *Operation, resp response) (any, error)
	decodeError(resp response) apiError
}

var protocolPreference = []struct {
	id       string
	protocol protocol
}{
	{"aws.protocols#awsJson1_0", awsJSON{version: "1.0"}},
	{"aws.protocols#awsJson1_1", awsJSON{version: "1.1"}},
	{"aws.protocols#ec2Query", ec2Query{}},
}

func protocolFor(traits Traits) (protocol, error) {
	for _, p := range protocolPreference {
		if traits.Has(p.id) {
			return p.protocol, nil
		}
	}
	return nil, fmt.Errorf("no supported protocol")
}
