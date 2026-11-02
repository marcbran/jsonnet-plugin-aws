//go:build e2e

package tests

import (
	"context"

	sdkaws "github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/opensearch"
	"github.com/stretchr/testify/require"
)

func (s *Stage) a_domain(region string, name string, engineVersion string) *Stage {
	_, err := s.opensearchClient(region).CreateDomain(context.Background(), &opensearch.CreateDomainInput{
		DomainName:    sdkaws.String(name),
		EngineVersion: sdkaws.String(engineVersion),
	})
	require.NoError(s.t, err)
	return s
}

func (s *Stage) opensearchClient(region string) *opensearch.Client {
	key := s.account + "/" + region
	client, ok := s.opensearch[key]
	if !ok {
		client = opensearch.NewFromConfig(flociConfig(s.account, region))
		s.opensearch[key] = client
	}
	return client
}
