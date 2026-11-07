//go:build e2e

package tests

import (
	"bytes"
	"context"

	sdkaws "github.com/aws/aws-sdk-go-v2/aws"
	"github.com/marcbran/jpoet/pkg/jpoet"
	"github.com/marcbran/jsonnet-plugin-aws/aws"
	"github.com/marcbran/jsonnet-plugin-aws/services/ec2"
	"github.com/marcbran/jsonnet-plugin-aws/services/ecr"
	"github.com/marcbran/jsonnet-plugin-aws/services/iam"
	"github.com/marcbran/jsonnet-plugin-aws/services/opensearch"
	"github.com/marcbran/jsonnet-plugin-aws/services/rds"
	"github.com/marcbran/jsonnet-plugin-aws/services/s3"
)

type Facade interface {
	Evaluate(ctx context.Context, snippet string) (string, error)
	Close() error
}

type JpoetFacade struct {
	plugin *jpoet.Plugin
	env    *jpoet.Environment
}

func NewE2EFacade(endpoint string, imports map[string]string) Facade {
	plugin := aws.Plugin(
		aws.WithServices(ecr.Service, ec2.Service, iam.Service, opensearch.Service, rds.Service, s3.Service),
		aws.WithEndpointResolver(func(*aws.Service, string) (string, error) {
			return endpoint, nil
		}),
		aws.WithCredentialsByRequest(func(_ context.Context, ci aws.CallInput) (sdkaws.Credentials, error) {
			return flociCredentials(ci.Account), nil
		}),
	)
	opts := []jpoet.EnvOption{
		jpoet.EnvWithPlugin(plugin),
		jpoet.EnvFileImport([]string{".."}),
	}
	for filename, content := range imports {
		opts = append(opts, jpoet.EnvStringImport(filename, content))
	}
	env := jpoet.Env(opts...)
	return &JpoetFacade{plugin: plugin, env: env}
}

func (f *JpoetFacade) Evaluate(ctx context.Context, snippet string) (string, error) {
	var out bytes.Buffer
	err := f.env.Eval(ctx,
		jpoet.EvalSnippetInput("main.jsonnet", snippet),
		jpoet.EvalWriterOutput(&out),
	)
	return out.String(), err
}

func (f *JpoetFacade) Close() error {
	return f.env.Close()
}
