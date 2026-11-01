//go:build e2e

package tests

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/ecr"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const evaluationTimeout = 30 * time.Second

type Stage struct {
	t *testing.T

	facade       Facade
	account      string
	otherAccount string
	ecr          map[string]*ecr.Client
	ec2          map[string]*ec2.Client
	vpcs         map[string]string

	LastOutput string
	LastError  string
}

func scenario(t *testing.T) (*Stage, *Stage, *Stage) {
	account := newFlociAccount()
	otherAccount := newFlociAccount()
	s := &Stage{
		t: t,
		facade: NewE2EFacade(flociEndpoint, map[string]string{
			"ctx.libsonnet":           fmt.Sprintf(`{ account: '%s', region: '%s' }`, account, flociRegion),
			"other-account.libsonnet": fmt.Sprintf(`'%s'`, otherAccount),
		}),
		account:      account,
		otherAccount: otherAccount,
		ecr:          map[string]*ecr.Client{},
		ec2:          map[string]*ec2.Client{},
		vpcs:         map[string]string{},
	}
	t.Cleanup(s.close)
	return s, s, s
}

func (s *Stage) close() {
	_ = s.facade.Close()
}

func (s *Stage) and() *Stage {
	return s
}

func (s *Stage) the_jsonnet_is_evaluated(snippet string) *Stage {
	ctx, cancel := context.WithTimeout(context.Background(), evaluationTimeout)
	defer cancel()
	out, err := s.facade.Evaluate(ctx, snippet)
	s.LastOutput = out
	s.LastError = ""
	if err != nil {
		s.LastError = err.Error()
	}
	return s
}

func (s *Stage) there_is_no_error() *Stage {
	require.Empty(s.t, s.LastError)
	return s
}

func (s *Stage) the_output_is(expected string) *Stage {
	assert.JSONEq(s.t, expected, s.LastOutput)
	return s
}
