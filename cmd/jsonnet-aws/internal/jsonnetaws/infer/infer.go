package infer

import (
	"context"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/inference"
	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/infra/codex"
	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/infra/files"
	infrajsonnet "github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/infra/jsonnet"
	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/jsonnetaws/tree"
)

type Progress = inference.Progress

type Input struct {
	Service   string
	Resources string
	Out       string
	WorkDir   string
	Model     string
	Limit     int
	Force     bool
	Progress  inference.Progress
}

type Output struct {
	Out     string   `json:"out"`
	WorkDir string   `json:"workDir"`
	Files   []string `json:"files"`
}

type Kind struct {
	Name           string
	Lib            fs.FS
	OutputTemplate string
	Jobs           func(renderer Renderer) []*TemplateJob
}

func Exec(ctx context.Context, loader inference.ModelLoader, kind Kind, in Input) (Output, error) {
	workDir := in.WorkDir
	if workDir == "" {
		workDir = in.Service
	}
	workDir, err := filepath.Abs(workDir)
	if err != nil {
		return Output{}, err
	}
	out := in.Out
	if out == "" {
		out = filepath.Join(workDir, kind.Name+".json")
	}
	out, err = filepath.Abs(out)
	if err != nil {
		return Output{}, err
	}
	resourcesPath := in.Resources
	if resourcesPath == "" {
		resourcesPath = filepath.Join(workDir, "resources.json")
	}
	resources, err := readResources(resourcesPath)
	if err != nil {
		return Output{}, err
	}
	model, err := loader.LoadModel(ctx, in.Service)
	if err != nil {
		return Output{}, err
	}
	sharedLib, err := inference.Lib()
	if err != nil {
		return Output{}, err
	}
	renderer := infrajsonnet.NewRenderer(kind.Lib, sharedLib, tree.FS())
	templateJobs := kind.Jobs(renderer)
	jobs := make([]inference.Job, 0, len(templateJobs))
	for _, job := range templateJobs {
		jobs = append(jobs, job)
	}
	pipeline := inference.Pipeline{
		Jobs:     jobs,
		Runner:   codex.NewRunner(in.Model),
		Store:    files.NewStore(workDir),
		Force:    in.Force,
		Limit:    in.Limit,
		Progress: in.Progress,
	}
	doc := inference.ModelDocument{Service: in.Service, Model: model, Resources: resources}
	results, rejections, err := pipeline.Exec(ctx, doc)
	if err != nil {
		return Output{}, err
	}
	bindings := []infrajsonnet.Binding{
		{Name: "model", Value: model},
		{Name: "resources", Value: resources},
	}
	for _, job := range templateJobs {
		bindings = append(bindings, infrajsonnet.Binding{Name: jsonnetName(job.Name()), Value: results[job.Name()]})
	}
	rendered, err := renderer.RenderOutput(kind.OutputTemplate, bindings...)
	if err != nil {
		return Output{}, err
	}
	err = os.MkdirAll(filepath.Dir(out), 0755)
	if err != nil {
		return Output{}, err
	}
	err = os.WriteFile(out, rendered, 0644)
	if err != nil {
		return Output{}, err
	}
	files := []string{}
	for _, job := range templateJobs {
		files = append(files, relativeOrAbs(workDir, filepath.Join(workDir, job.Name(), "results", "all.jsonnet")))
	}
	result := Output{Out: out, WorkDir: workDir, Files: append(files, out)}
	if len(rejections) > 0 {
		return result, rejectionError(rejections)
	}
	return result, nil
}

func rejectionError(rejections []inference.Rejection) error {
	var b strings.Builder
	fmt.Fprintf(&b, "%d task(s) still failed validation after a retry and were not cached; rerun them or correct them by hand:", len(rejections))
	for _, r := range rejections {
		fmt.Fprintf(&b, "\n  %s/%s:", r.JobName, r.TaskID)
		for _, problem := range r.Problems {
			fmt.Fprintf(&b, "\n    - %s", problem)
		}
	}
	return errors.New(b.String())
}

func readResources(path string) (string, error) {
	raw, err := os.ReadFile(path)
	if os.IsNotExist(err) {
		return "{}", nil
	}
	if err != nil {
		return "", err
	}
	return string(raw), nil
}

func jsonnetName(name string) string {
	out := []rune{}
	upper := false
	for _, r := range name {
		if r == '-' {
			upper = true
			continue
		}
		if upper && r >= 'a' && r <= 'z' {
			r = r - 'a' + 'A'
		}
		upper = false
		out = append(out, r)
	}
	return string(out)
}

func relativeOrAbs(base, target string) string {
	rel, err := filepath.Rel(base, target)
	if err != nil {
		return target
	}
	return rel
}
