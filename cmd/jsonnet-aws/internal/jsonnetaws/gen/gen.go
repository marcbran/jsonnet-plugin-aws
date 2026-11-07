package gen

import (
	"context"
	"embed"
	"encoding/json"
	"io/fs"
	"os"
	"path/filepath"
	"sort"

	"github.com/marcbran/jpoet/pkg/jpoet"
	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/inference"
	infrajsonnet "github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/infra/jsonnet"
	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/jsonnetaws/tree"
)

//go:embed lib
var genLib embed.FS

type Input struct {
	Service string
	Inputs  string
	Out     string
	Plugins []*jpoet.Plugin
}

type Output struct {
	Dir   string   `json:"dir"`
	Files []string `json:"files"`
}

func Exec(ctx context.Context, loader inference.ModelLoader, in Input) (Output, error) {
	inputs := in.Inputs
	if inputs == "" {
		inputs = filepath.Join(in.Service, "inference")
	}
	inputs, err := filepath.Abs(inputs)
	if err != nil {
		return Output{}, err
	}
	dir := in.Out
	if dir == "" {
		dir = filepath.Join(in.Service, "arcourse")
	}
	dir, err = filepath.Abs(dir)
	if err != nil {
		return Output{}, err
	}
	model, err := loader.LoadModel(ctx, in.Service)
	if err != nil {
		return Output{}, err
	}
	resources, err := readJSON(filepath.Join(inputs, "resources.json"), "{}")
	if err != nil {
		return Output{}, err
	}
	columns, err := readJSON(filepath.Join(inputs, "columns.json"), "[]")
	if err != nil {
		return Output{}, err
	}
	links, err := readJSON(filepath.Join(inputs, "links.json"), "[]")
	if err != nil {
		return Output{}, err
	}
	sub, err := fs.Sub(genLib, "lib")
	if err != nil {
		return Output{}, err
	}
	service, err := json.Marshal(in.Service)
	if err != nil {
		return Output{}, err
	}
	renderer := infrajsonnet.NewRenderer(sub, tree.FS()).WithPlugins(in.Plugins...)
	rendered, err := renderer.RenderOutput(ctx, "gen.jsonnet",
		infrajsonnet.Binding{Name: "service", Value: string(service)},
		infrajsonnet.Binding{Name: "model", Value: model},
		infrajsonnet.Binding{Name: "resources", Value: resources},
		infrajsonnet.Binding{Name: "columns", Value: columns},
		infrajsonnet.Binding{Name: "links", Value: links},
	)
	if err != nil {
		return Output{}, err
	}
	var generated map[string]string
	err = json.Unmarshal(rendered, &generated)
	if err != nil {
		return Output{}, err
	}
	err = os.MkdirAll(dir, 0755)
	if err != nil {
		return Output{}, err
	}
	names := make([]string, 0, len(generated))
	for name := range generated {
		names = append(names, name)
	}
	sort.Strings(names)
	files := make([]string, 0, len(names))
	for _, name := range names {
		path := filepath.Join(dir, name)
		err = os.WriteFile(path, []byte(generated[name]), 0644)
		if err != nil {
			return Output{}, err
		}
		files = append(files, path)
	}
	return Output{Dir: dir, Files: files}, nil
}

func readJSON(path string, fallback string) (string, error) {
	raw, err := os.ReadFile(path)
	if os.IsNotExist(err) {
		return fallback, nil
	}
	if err != nil {
		return "", err
	}
	return string(raw), nil
}
