//go:build e2e

package tests

import (
	"context"
	"fmt"
	"sync/atomic"
	"time"

	sdkaws "github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

const (
	flociImage  = "floci/floci:2.4.0"
	flociPort   = "4566/tcp"
	flociRegion = "eu-west-1"
)

var flociEndpoint string

var lastFlociAccount atomic.Int64

func startFloci(ctx context.Context) (testcontainers.Container, error) {
	container, err := testcontainers.Run(ctx, flociImage,
		testcontainers.WithExposedPorts(flociPort),
		testcontainers.WithWaitStrategy(
			wait.ForHTTP("/_localstack/health").WithPort(flociPort).WithStartupTimeout(2*time.Minute),
		),
	)
	if err != nil {
		return container, err
	}
	endpoint, err := container.PortEndpoint(ctx, flociPort, "http")
	if err != nil {
		return container, err
	}
	flociEndpoint = endpoint
	return container, nil
}

func newFlociAccount() string {
	return fmt.Sprintf("%012d", 100000000000+lastFlociAccount.Add(1))
}

func flociCredentials(account string) sdkaws.Credentials {
	return sdkaws.Credentials{AccessKeyID: account, SecretAccessKey: "test", Source: "floci"}
}

func flociConfig(account string, region string) sdkaws.Config {
	return sdkaws.Config{
		Region:       region,
		Credentials:  credentials.StaticCredentialsProvider{Value: flociCredentials(account)},
		BaseEndpoint: sdkaws.String(flociEndpoint),
	}
}
