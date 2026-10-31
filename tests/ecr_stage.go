//go:build e2e

package tests

import (
	"context"

	sdkaws "github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/ecr"
	"github.com/stretchr/testify/require"
)

func (s *Stage) an_ecr_repository(name string) *Stage {
	return s.an_ecr_repository_in(s.account, flociRegion, name)
}

func (s *Stage) an_ecr_repository_in_region(region string, name string) *Stage {
	return s.an_ecr_repository_in(s.account, region, name)
}

func (s *Stage) an_ecr_repository_in_the_other_account(name string) *Stage {
	return s.an_ecr_repository_in(s.otherAccount, flociRegion, name)
}

func (s *Stage) an_ecr_repository_in(account string, region string, name string) *Stage {
	_, err := s.ecrClient(account, region).CreateRepository(context.Background(), &ecr.CreateRepositoryInput{
		RepositoryName: sdkaws.String(name),
	})
	require.NoError(s.t, err)
	return s
}

func (s *Stage) ecrClient(account string, region string) *ecr.Client {
	key := account + "/" + region
	client, ok := s.ecr[key]
	if !ok {
		client = ecr.NewFromConfig(flociConfig(account, region))
		s.ecr[key] = client
	}
	return client
}
