package infer

import (
	"context"
	"encoding/json"

	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/inference"
)

type Renderer interface {
	inference.BundleRenderer
	RenderCheck(template string, input, output []byte) ([]byte, []string, error)
}

type TemplateJob struct {
	JobName         string
	BundlesTemplate string
	CheckTemplate   string
	Prompt          string
	Schema          []byte
	EchoedFields    []string
	Renderer        Renderer
}

func (j *TemplateJob) Name() string {
	return j.JobName
}

func (j *TemplateJob) TransformOutput(task inference.Task, output []byte) ([]byte, error) {
	return overrideEchoedFields(task.Input, output, j.EchoedFields...)
}

func (j *TemplateJob) ValidateOutput(task inference.Task, output []byte) ([]byte, []string, error) {
	return j.Renderer.RenderCheck(j.CheckTemplate, task.Input, output)
}

func (j *TemplateJob) Build(ctx context.Context, doc inference.ModelDocument, previous inference.Results) ([]inference.Task, error) {
	bundles, err := j.Renderer.RenderBundles(j.BundlesTemplate, doc)
	if err != nil {
		return nil, err
	}
	tasks := make([]inference.Task, 0, len(bundles))
	for _, bundle := range bundles {
		tasks = append(tasks, inference.Task{
			JobName:      j.Name(),
			ID:           bundle.ID,
			Input:        bundle.Input,
			Prompt:       j.Prompt,
			OutputSchema: j.Schema,
		})
	}
	return tasks, nil
}

func overrideEchoedFields(input, output []byte, fields ...string) ([]byte, error) {
	if len(fields) == 0 {
		return output, nil
	}
	var in map[string]json.RawMessage
	err := json.Unmarshal(input, &in)
	if err != nil {
		return nil, err
	}
	var out map[string]json.RawMessage
	err = json.Unmarshal(output, &out)
	if err != nil {
		return nil, err
	}
	for _, field := range fields {
		if v, ok := in[field]; ok {
			out[field] = v
		}
	}
	return json.Marshal(out)
}
