//go:build e2e

package tests

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	awspkg "github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/pkg/jsonnetaws"
)

type CLIFacade struct {
	binaryPath string
	codexLog   string
}

func NewCLIFacade(codexLog string) (awspkg.Facade, error) {
	binaryPath := os.Getenv("JSONNET_AWS_BINARY")
	if binaryPath == "" {
		return nil, fmt.Errorf("JSONNET_AWS_BINARY is required")
	}
	_, err := os.Stat(binaryPath)
	if err != nil {
		return nil, fmt.Errorf("unable to access JSONNET_AWS_BINARY %q: %w", binaryPath, err)
	}
	return &CLIFacade{binaryPath: binaryPath, codexLog: codexLog}, nil
}

func (f *CLIFacade) Generate(ctx context.Context, in awspkg.GenerateInput) (awspkg.GenerateOutput, error) {
	args := []string{"gen", in.Service}
	if in.Inputs != "" {
		args = append(args, "--inputs", in.Inputs)
	}
	if in.Out != "" {
		args = append(args, "--out", in.Out)
	}
	cmd := exec.CommandContext(ctx, f.binaryPath, args...)
	var stdout bytes.Buffer
	var stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		if stderr.String() != "" {
			return awspkg.GenerateOutput{}, errors.New(stderr.String())
		}
		return awspkg.GenerateOutput{}, err
	}
	return awspkg.GenerateOutput{Dir: in.Out, Files: strings.Fields(stdout.String())}, nil
}

func (f *CLIFacade) InferResources(ctx context.Context, in awspkg.InferInput) (awspkg.InferOutput, error) {
	return f.infer(ctx, "resources", in)
}

func (f *CLIFacade) InferColumns(ctx context.Context, in awspkg.InferInput) (awspkg.InferOutput, error) {
	return f.infer(ctx, "columns", in)
}

func (f *CLIFacade) InferLinks(ctx context.Context, in awspkg.InferInput) (awspkg.InferOutput, error) {
	return f.infer(ctx, "links", in)
}

func (f *CLIFacade) infer(ctx context.Context, kind string, in awspkg.InferInput) (awspkg.InferOutput, error) {
	args := []string{kind, "infer", in.Service, "-q"}
	if in.Out != "" {
		args = append(args, "--out", in.Out)
	}
	if in.WorkDir != "" {
		args = append(args, "--workdir", in.WorkDir)
	}
	if in.Resources != "" {
		args = append(args, "--resources", in.Resources)
	}
	if in.Model != "" {
		args = append(args, "--model", in.Model)
	}
	if in.Limit > 0 {
		args = append(args, "--limit", fmt.Sprintf("%d", in.Limit))
	}
	if in.Force {
		args = append(args, "--force")
	}
	cmd := exec.CommandContext(ctx, f.binaryPath, args...)
	cmd.Env = append(os.Environ(),
		"PATH="+filepath.Join(testdataRoot(), "bin")+string(os.PathListSeparator)+os.Getenv("PATH"),
		"FAKE_CODEX_LOG="+f.codexLog,
	)
	var stdout bytes.Buffer
	var stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		if stderr.String() != "" {
			return awspkg.InferOutput{}, errors.New(stderr.String())
		}
		return awspkg.InferOutput{}, err
	}
	return awspkg.InferOutput{
		Out:     strings.TrimSpace(stdout.String()),
		WorkDir: in.WorkDir,
	}, nil
}
