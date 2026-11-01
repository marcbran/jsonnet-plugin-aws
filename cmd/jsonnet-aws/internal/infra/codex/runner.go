package codex

import (
	"bytes"
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/inference"
)

type Runner struct {
	model string
}

func NewRunner(model string) *Runner {
	return &Runner{model: model}
}

func (r *Runner) Exec(ctx context.Context, task inference.Task) ([]byte, error) {
	dir, err := os.MkdirTemp("", "jsonnet-aws-codex-*")
	if err != nil {
		return nil, err
	}
	defer func() {
		_ = os.RemoveAll(dir)
	}()

	inputPath := filepath.Join(dir, "input.json")
	err = os.WriteFile(inputPath, task.Input, 0644)
	if err != nil {
		return nil, err
	}
	err = os.WriteFile(filepath.Join(dir, "prompt.md"), []byte(task.Prompt), 0644)
	if err != nil {
		return nil, err
	}
	schemaPath := filepath.Join(dir, "schema.json")
	err = os.WriteFile(schemaPath, task.OutputSchema, 0644)
	if err != nil {
		return nil, err
	}
	outputPath := filepath.Join(dir, "output.json")

	args := []string{
		"exec",
		"--cd", dir,
		"--skip-git-repo-check",
		"--ephemeral",
		"--sandbox", "read-only",
	}
	// Only override the model when one was asked for. Otherwise let codex use
	// the model from its own config, so there is no default here to go stale as
	// models are released.
	if r.model != "" {
		args = append(args, "--model", r.model)
	}
	args = append(args,
		"--output-schema", schemaPath,
		"--output-last-message", outputPath,
		"Read prompt.md and input.json. Return only JSON.",
	)
	cmd := exec.CommandContext(ctx, "codex", args...)
	cmd.Stdin = strings.NewReader("")
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	err = cmd.Run()
	if err != nil {
		msg := strings.TrimSpace(stderr.String())
		if msg != "" {
			return nil, fmt.Errorf("codex exec failed for %s/%s: %w: %s", task.JobName, task.ID, err, msg)
		}
		return nil, fmt.Errorf("codex exec failed for %s/%s: %w", task.JobName, task.ID, err)
	}
	return os.ReadFile(outputPath)
}
