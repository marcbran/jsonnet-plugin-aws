package jsonnetaws

import "context"

type InferInput struct {
	Service   string `json:"service"`
	Resources string `json:"resources,omitempty"`
	Out       string `json:"out,omitempty"`
	WorkDir   string `json:"workDir,omitempty"`
	Model     string `json:"model,omitempty"`
	Limit     int    `json:"limit,omitempty"`
	Force     bool   `json:"force,omitempty"`
}

type InferOutput struct {
	Out     string   `json:"out"`
	WorkDir string   `json:"workDir"`
	Files   []string `json:"files"`
}

type GenerateInput struct {
	Service string `json:"service"`
	Inputs  string `json:"inputs,omitempty"`
	Out     string `json:"out,omitempty"`
}

type GenerateOutput struct {
	Dir   string   `json:"dir"`
	Files []string `json:"files"`
}

type Facade interface {
	Generate(ctx context.Context, in GenerateInput) (GenerateOutput, error)
	InferResources(ctx context.Context, in InferInput) (InferOutput, error)
	InferColumns(ctx context.Context, in InferInput) (InferOutput, error)
	InferLinks(ctx context.Context, in InferInput) (InferOutput, error)
}
