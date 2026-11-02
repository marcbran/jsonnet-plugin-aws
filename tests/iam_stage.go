//go:build e2e

package tests

import (
	"context"

	sdkaws "github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/iam"
	"github.com/aws/aws-sdk-go-v2/service/iam/types"
	"github.com/stretchr/testify/require"
)

func (s *Stage) a_user(path string, name string, tags map[string]string) *Stage {
	input := &iam.CreateUserInput{UserName: sdkaws.String(name), Path: sdkaws.String(path)}
	for k, v := range tags {
		input.Tags = append(input.Tags, types.Tag{Key: sdkaws.String(k), Value: sdkaws.String(v)})
	}
	_, err := s.iamClient().CreateUser(context.Background(), input)
	require.NoError(s.t, err)
	return s
}

func (s *Stage) a_role(name string) *Stage {
	_, err := s.iamClient().CreateRole(context.Background(), &iam.CreateRoleInput{
		RoleName:                 sdkaws.String(name),
		AssumeRolePolicyDocument: sdkaws.String(`{"Version":"2012-10-17","Statement":[]}`),
	})
	require.NoError(s.t, err)
	return s
}

func (s *Stage) iamClient() *iam.Client {
	if s.iam == nil {
		s.iam = iam.NewFromConfig(flociConfig(s.account, "us-east-1"))
	}
	return s.iam
}
