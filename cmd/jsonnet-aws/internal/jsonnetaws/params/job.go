package params

import (
	"embed"
	"io/fs"

	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/jsonnetaws/infer"
)

const JobName = "params-inference"

//go:embed schemas/params-inference-output.schema.json
var schema []byte

//go:embed lib
var lib embed.FS

func Kind() (infer.Kind, error) {
	sub, err := fs.Sub(lib, "lib")
	if err != nil {
		return infer.Kind{}, err
	}
	return infer.Kind{
		Name:           "params",
		Lib:            sub,
		OutputTemplate: "params.jsonnet",
		Jobs: func(renderer infer.Renderer) []*infer.TemplateJob {
			return []*infer.TemplateJob{{
				JobName:         JobName,
				BundlesTemplate: "params-bundles.jsonnet",
				CheckTemplate:   "params-output-check.jsonnet",
				Prompt:          paramsPrompt,
				Schema:          schema,
				EchoedFields:    []string{"operation"},
				Renderer:        renderer,
			}}
		},
	}, nil
}
