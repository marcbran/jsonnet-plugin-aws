package jsonnet

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/marcbran/jpoet/pkg/jpoet"
	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/inference"
)

type Renderer struct {
	imports []fs.FS
	plugins []*jpoet.Plugin
}

type Binding struct {
	Name  string
	Value string
}

func NewRenderer(imports ...fs.FS) *Renderer {
	return &Renderer{imports: imports}
}

func (r *Renderer) WithPlugins(plugins ...*jpoet.Plugin) *Renderer {
	return &Renderer{imports: r.imports, plugins: append(r.plugins, plugins...)}
}

func (r *Renderer) RenderBundles(template string, doc inference.ModelDocument) ([]inference.Bundle, error) {
	dir, err := os.MkdirTemp("", "jsonnet-aws-inference-*")
	if err != nil {
		return nil, err
	}
	defer func() {
		_ = os.RemoveAll(dir)
	}()

	input := jpoet.SnippetInput(template, fmt.Sprintf(
		"local model = %s; local resources = %s; (import %q)(model, resources)",
		doc.Model,
		doc.Resources,
		template,
	))
	opts := make([]jpoet.Option, 0, len(r.imports)+3)
	for _, imp := range r.imports {
		opts = append(opts, jpoet.FSImport(imp))
	}
	opts = append(opts, input, jpoet.Serialize(false), jpoet.DirectoryOutput(dir))
	err = jpoet.Eval(opts...)
	if err != nil {
		return nil, err
	}

	inputs, err := filepath.Glob(filepath.Join(dir, "*", "input.json"))
	if err != nil {
		return nil, err
	}
	sort.Strings(inputs)
	bundles := make([]inference.Bundle, 0, len(inputs))
	for _, input := range inputs {
		raw, err := os.ReadFile(input)
		if err != nil {
			return nil, err
		}
		bundles = append(bundles, inference.Bundle{
			ID:    filepath.Base(filepath.Dir(input)),
			Input: raw,
		})
	}
	return bundles, nil
}

func (r *Renderer) RenderOutput(template string, bindings ...Binding) ([]byte, error) {
	var locals bytes.Buffer
	names := make([]string, 0, len(bindings))
	for _, binding := range bindings {
		fmt.Fprintf(&locals, "local %s = %s; ", binding.Name, binding.Value)
		names = append(names, binding.Name)
	}

	var out bytes.Buffer
	opts := make([]jpoet.Option, 0, len(r.imports)+len(r.plugins)+2)
	for _, imp := range r.imports {
		opts = append(opts, jpoet.FSImport(imp))
	}
	for _, p := range r.plugins {
		opts = append(opts, jpoet.WithPlugin(p))
	}
	opts = append(opts,
		jpoet.SnippetInput(template, fmt.Sprintf("%s(import %q)(%s)", locals.String(), template, strings.Join(names, ", "))),
		jpoet.WriterOutput(&out),
	)
	err := jpoet.Eval(opts...)
	if err != nil {
		return nil, err
	}
	return out.Bytes(), nil
}

func (r *Renderer) RenderCheck(template string, input, output []byte) ([]byte, []string, error) {
	rendered, err := r.RenderOutput(template,
		Binding{Name: "input", Value: string(input)},
		Binding{Name: "output", Value: string(output)},
	)
	if err != nil {
		return nil, nil, err
	}
	var checked struct {
		Valid    json.RawMessage `json:"valid"`
		Problems []string        `json:"problems"`
	}
	err = json.Unmarshal(rendered, &checked)
	if err != nil {
		return nil, nil, err
	}
	var valid bytes.Buffer
	err = json.Compact(&valid, checked.Valid)
	if err != nil {
		return nil, nil, err
	}
	return valid.Bytes(), checked.Problems, nil
}
