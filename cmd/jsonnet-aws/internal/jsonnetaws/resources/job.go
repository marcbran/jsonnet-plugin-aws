package resources

import (
	"embed"
	"io/fs"

	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/jsonnetaws/infer"
)

const JobName = "resources-inference"

const ItemsJobName = "items-inference"

//go:embed schemas/resources-inference-output.schema.json
var schema []byte

//go:embed schemas/items-inference-output.schema.json
var itemsSchema []byte

//go:embed lib
var lib embed.FS

func Kind() (infer.Kind, error) {
	sub, err := fs.Sub(lib, "lib")
	if err != nil {
		return infer.Kind{}, err
	}
	return infer.Kind{
		Name:           "resources",
		Lib:            sub,
		OutputTemplate: "resources.jsonnet",
		Jobs: func(renderer infer.Renderer) []*infer.TemplateJob {
			return []*infer.TemplateJob{{
				JobName:         ItemsJobName,
				BundlesTemplate: "items-bundles.jsonnet",
				CheckTemplate:   "items-output-check.jsonnet",
				Prompt:          itemsPrompt,
				Schema:          itemsSchema,
				EchoedFields:    []string{"operation"},
				Renderer:        renderer,
			}, {
				JobName:         JobName,
				BundlesTemplate: "resources-bundles.jsonnet",
				CheckTemplate:   "resources-output-check.jsonnet",
				Prompt:          resourcesPrompt,
				Schema:          schema,
				EchoedFields:    []string{"operation"},
				Renderer:        renderer,
			}}
		},
	}, nil
}
