//go:build e2e

package tests

import (
	"context"
	"strings"

	sdkaws "github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
	"github.com/stretchr/testify/require"
)

func (s *Stage) a_bucket(region string, name string) *Stage {
	input := &s3.CreateBucketInput{Bucket: sdkaws.String(name)}
	if region != "us-east-1" {
		input.CreateBucketConfiguration = &types.CreateBucketConfiguration{LocationConstraint: types.BucketLocationConstraint(region)}
	}
	_, err := s.s3Client(region).CreateBucket(context.Background(), input)
	require.NoError(s.t, err)
	return s
}

func (s *Stage) an_object(bucket string, key string, body string) *Stage {
	_, err := s.s3Client(flociRegion).PutObject(context.Background(), &s3.PutObjectInput{
		Bucket:      sdkaws.String(bucket),
		Key:         sdkaws.String(key),
		Body:        strings.NewReader(body),
		ContentType: sdkaws.String("text/plain"),
	})
	require.NoError(s.t, err)
	return s
}

func (s *Stage) a_bucket_policy(bucket string, policy string) *Stage {
	_, err := s.s3Client(flociRegion).PutBucketPolicy(context.Background(), &s3.PutBucketPolicyInput{
		Bucket: sdkaws.String(bucket),
		Policy: sdkaws.String(policy),
	})
	require.NoError(s.t, err)
	return s
}

func (s *Stage) s3Client(region string) *s3.Client {
	key := s.account + "/" + region
	client, ok := s.s3[key]
	if !ok {
		client = s3.NewFromConfig(flociConfig(s.account, region), func(o *s3.Options) {
			o.UsePathStyle = true
		})
		s.s3[key] = client
	}
	return client
}
