//go:build e2e

package tests

import (
	"context"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"testing"

	awspkg "github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/pkg/jsonnetaws"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type inferCall func(f awspkg.Facade, ctx context.Context, in awspkg.InferInput) (awspkg.InferOutput, error)

type Stage struct {
	t *testing.T

	facade   awspkg.Facade
	tempDir  string
	codexLog string

	input      awspkg.InferInput
	serviceDir string

	lastOutput         awspkg.InferOutput
	lastGenerateOutput awspkg.GenerateOutput
	lastErr            string
}

func scenario(t *testing.T) (*Stage, *Stage, *Stage) {
	tempDir := t.TempDir()
	codexLog := filepath.Join(tempDir, "codex.log")
	facade, err := NewCLIFacade(codexLog)
	require.NoError(t, err)
	s := &Stage{
		t:        t,
		facade:   facade,
		tempDir:  tempDir,
		codexLog: codexLog,
		input: awspkg.InferInput{
			WorkDir: filepath.Join(tempDir, "work"),
		},
	}
	return s, s, s
}

func (s *Stage) and() *Stage {
	return s
}

func (s *Stage) the_service(service string) *Stage {
	s.input.Service = service
	return s
}

func (s *Stage) the_resource_overrides(fixture string) *Stage {
	s.input.Resources = filepath.Join(testdataRoot(), fixture)
	return s
}

func (s *Stage) a_cached_result(job string, operation string, result string) *Stage {
	path := filepath.Join(s.input.WorkDir, job, "results", operation+".json")
	err := os.MkdirAll(filepath.Dir(path), 0755)
	require.NoError(s.t, err)
	err = os.WriteFile(path, []byte(result), 0644)
	require.NoError(s.t, err)
	return s
}

func (s *Stage) the_output_file(name string) *Stage {
	s.input.Out = filepath.Join(s.tempDir, name)
	return s
}

func (s *Stage) the_command_is_run(call inferCall) *Stage {
	out, err := call(s.facade, context.Background(), s.input)
	s.lastOutput = out
	s.lastErr = ""
	if err != nil {
		s.lastErr = err.Error()
	}
	return s
}

func (s *Stage) there_is_no_error() *Stage {
	require.Empty(s.t, s.lastErr)
	return s
}

func (s *Stage) the_error_mentions(text string) *Stage {
	assert.Contains(s.t, s.lastErr, text)
	return s
}

func (s *Stage) the_output_matches(fixture string) *Stage {
	out := s.lastOutput.Out
	if out == "" {
		out = s.input.Out
	}
	raw, err := os.ReadFile(out)
	require.NoError(s.t, err)
	expected, err := os.ReadFile(filepath.Join(testdataRoot(), fixture))
	require.NoError(s.t, err)
	assert.JSONEq(s.t, string(expected), string(raw))
	return s
}

func (s *Stage) codex_was_not_called_for(operations ...string) *Stage {
	called := s.codexCalls()
	for _, operation := range operations {
		assert.NotContains(s.t, called, operation)
	}
	return s
}

func (s *Stage) codex_was_not_called() *Stage {
	assert.Empty(s.t, s.codexCalls())
	return s
}

func (s *Stage) no_result_is_cached(job string, operation string) *Stage {
	_, err := os.Stat(filepath.Join(s.input.WorkDir, job, "results", operation+".json"))
	assert.True(s.t, os.IsNotExist(err), "%s/%s should not be cached", job, operation)
	return s
}

func (s *Stage) codexCalls() []string {
	raw, err := os.ReadFile(s.codexLog)
	if os.IsNotExist(err) {
		return nil
	}
	require.NoError(s.t, err)
	return strings.Fields(string(raw))
}

func testdataRoot() string {
	_, file, _, _ := runtime.Caller(0)
	return filepath.Join(filepath.Dir(file), "testdata")
}
