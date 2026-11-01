package columns

import (
	"embed"
	"io/fs"

	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/jsonnetaws/infer"
)

const JobName = "columns-inference"

//go:embed schemas/columns-inference-output.schema.json
var schema []byte

//go:embed lib
var lib embed.FS

func Kind() (infer.Kind, error) {
	sub, err := fs.Sub(lib, "lib")
	if err != nil {
		return infer.Kind{}, err
	}
	return infer.Kind{
		Name:           "columns",
		Lib:            sub,
		OutputTemplate: "columns.jsonnet",
		Jobs: func(renderer infer.Renderer) []*infer.TemplateJob {
			return []*infer.TemplateJob{{
				JobName:         JobName,
				BundlesTemplate: "columns-bundles.jsonnet",
				CheckTemplate:   "columns-output-check.jsonnet",
				Prompt:          columnsPrompt,
				Schema:          schema,
				EchoedFields:    []string{"operation", "array"},
				Renderer:        renderer,
			}}
		},
	}, nil
}
