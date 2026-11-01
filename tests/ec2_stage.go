//go:build e2e

package tests

import (
	"context"

	sdkaws "github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"github.com/stretchr/testify/require"
)

func (s *Stage) a_vpc(name string, cidr string) *Stage {
	out, err := s.ec2Client().CreateVpc(context.Background(), &ec2.CreateVpcInput{
		CidrBlock:         sdkaws.String(cidr),
		TagSpecifications: nameTag(types.ResourceTypeVpc, name),
	})
	require.NoError(s.t, err)
	s.vpcs[name] = *out.Vpc.VpcId
	return s
}

func (s *Stage) a_subnet(vpc string, name string, cidr string) *Stage {
	_, err := s.ec2Client().CreateSubnet(context.Background(), &ec2.CreateSubnetInput{
		VpcId:             sdkaws.String(s.vpcs[vpc]),
		CidrBlock:         sdkaws.String(cidr),
		TagSpecifications: nameTag(types.ResourceTypeSubnet, name),
	})
	require.NoError(s.t, err)
	return s
}

func (s *Stage) ec2Client() *ec2.Client {
	key := s.account + "/" + flociRegion
	client, ok := s.ec2[key]
	if !ok {
		client = ec2.NewFromConfig(flociConfig(s.account, flociRegion))
		s.ec2[key] = client
	}
	return client
}

func nameTag(resource types.ResourceType, name string) []types.TagSpecification {
	return []types.TagSpecification{{
		ResourceType: resource,
		Tags:         []types.Tag{{Key: sdkaws.String("Name"), Value: sdkaws.String(name)}},
	}}
}
