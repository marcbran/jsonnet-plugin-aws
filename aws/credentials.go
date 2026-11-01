package aws

import (
	"context"
	"fmt"

	sdkaws "github.com/aws/aws-sdk-go-v2/aws"
)

type CredentialsByRequest func(ctx context.Context, ci CallInput) (sdkaws.Credentials, error)

func noCredentials(context.Context, CallInput) (sdkaws.Credentials, error) {
	return sdkaws.Credentials{}, fmt.Errorf("no credentials configured")
}
