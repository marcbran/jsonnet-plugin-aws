//go:build e2e

package tests

import (
	"context"
	"os"
	"path/filepath"

	awspkg "github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/pkg/jsonnetaws"
	"github.com/stretchr/testify/require"
)

func (s *Stage) the_published_service_directory(service string) *Stage {
	s.input.Service = service
	s.serviceDir = filepath.Join(repoRoot(), "services", service)
	return s
}

func (s *Stage) the_nodes_are_generated() *Stage {
	out, err := s.facade.Generate(context.Background(), awspkg.GenerateInput{
		Service: s.input.Service,
		Inputs:  filepath.Join(s.serviceDir, "inference"),
		Out:     filepath.Join(s.tempDir, "arcourse"),
	})
	s.lastGenerateOutput = out
	s.lastErr = ""
	if err != nil {
		s.lastErr = err.Error()
	}
	return s
}

func (s *Stage) the_generated_package_matches_the_published_one() *Stage {
	require.Len(s.t, s.lastGenerateOutput.Files, 4)
	for _, file := range s.lastGenerateOutput.Files {
		name := filepath.Base(file)
		generated, err := os.ReadFile(file)
		require.NoError(s.t, err)
		published, err := os.ReadFile(filepath.Join(repoRoot(), "pkg", "arcourse-aws-"+s.input.Service, name))
		require.NoError(s.t, err)
		require.Equal(s.t, string(published), string(generated), "pkg/arcourse-aws-%s/%s is out of date; run `just arcourse-gen %s`", s.input.Service, name, s.input.Service)
	}
	return s
}

func repoRoot() string {
	return filepath.Join(testdataRoot(), "..", "..", "..", "..")
}
