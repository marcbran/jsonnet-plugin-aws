//go:build e2e

package tests

import (
	"context"

	sdkaws "github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/rds"
	"github.com/stretchr/testify/require"
)

func (s *Stage) a_db_parameter_group(region string, name string, family string) *Stage {
	_, err := s.rdsClient(region).CreateDBParameterGroup(context.Background(), &rds.CreateDBParameterGroupInput{
		DBParameterGroupName:   sdkaws.String(name),
		DBParameterGroupFamily: sdkaws.String(family),
		Description:            sdkaws.String(name),
	})
	require.NoError(s.t, err)
	return s
}

func (s *Stage) rdsClient(region string) *rds.Client {
	key := s.account + "/" + region
	client, ok := s.rds[key]
	if !ok {
		client = rds.NewFromConfig(flociConfig(s.account, region))
		s.rds[key] = client
	}
	return client
}
