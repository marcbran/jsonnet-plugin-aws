package links

import (
	"embed"
	"io/fs"

	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/jsonnetaws/infer"
)

const JobName = "links-inference"

//go:embed schemas/links-inference-output.schema.json
var schema []byte

//go:embed lib
var lib embed.FS

func Kind() (infer.Kind, error) {
	sub, err := fs.Sub(lib, "lib")
	if err != nil {
		return infer.Kind{}, err
	}
	return infer.Kind{
		Name:           "links",
		Lib:            sub,
		OutputTemplate: "links.jsonnet",
		Jobs: func(renderer infer.Renderer) []*infer.TemplateJob {
			return []*infer.TemplateJob{{
				JobName:         JobName,
				BundlesTemplate: "links-bundles.jsonnet",
				CheckTemplate:   "links-output-check.jsonnet",
				Prompt:          linksPrompt,
				Schema:          schema,
				EchoedFields:    []string{"operation"},
				Renderer:        renderer,
			}}
		},
	}, nil
}
