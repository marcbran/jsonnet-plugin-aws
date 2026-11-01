package jsonnetaws

import (
	"context"

	"github.com/marcbran/jpoet/pkg/jpoet"

	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/inference"
	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/jsonnetaws/columns"
	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/jsonnetaws/gen"
	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/jsonnetaws/infer"
	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/jsonnetaws/links"
	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/jsonnetaws/resources"
	awspkg "github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/pkg/jsonnetaws"
)

type facade struct {
	loader   inference.ModelLoader
	progress inference.Progress
	plugins  []*jpoet.Plugin
}

func NewFacade(loader inference.ModelLoader, progress inference.Progress, plugins ...*jpoet.Plugin) awspkg.Facade {
	return &facade{loader: loader, progress: progress, plugins: plugins}
}

func (f *facade) Generate(ctx context.Context, in awspkg.GenerateInput) (awspkg.GenerateOutput, error) {
	out, err := gen.Exec(ctx, f.loader, gen.Input{
		Service: in.Service,
		Inputs:  in.Inputs,
		Out:     in.Out,
		Plugins: f.plugins,
	})
	if err != nil {
		return awspkg.GenerateOutput{}, err
	}
	return awspkg.GenerateOutput{Dir: out.Dir, Files: out.Files}, nil
}

func (f *facade) InferResources(ctx context.Context, in awspkg.InferInput) (awspkg.InferOutput, error) {
	kind, err := resources.Kind()
	if err != nil {
		return awspkg.InferOutput{}, err
	}
	return f.infer(ctx, kind, in)
}

func (f *facade) InferColumns(ctx context.Context, in awspkg.InferInput) (awspkg.InferOutput, error) {
	kind, err := columns.Kind()
	if err != nil {
		return awspkg.InferOutput{}, err
	}
	return f.infer(ctx, kind, in)
}

func (f *facade) InferLinks(ctx context.Context, in awspkg.InferInput) (awspkg.InferOutput, error) {
	kind, err := links.Kind()
	if err != nil {
		return awspkg.InferOutput{}, err
	}
	return f.infer(ctx, kind, in)
}

func (f *facade) infer(ctx context.Context, kind infer.Kind, in awspkg.InferInput) (awspkg.InferOutput, error) {
	out, err := infer.Exec(ctx, f.loader, kind, infer.Input{
		Service:   in.Service,
		Resources: in.Resources,
		Out:       in.Out,
		WorkDir:   in.WorkDir,
		Model:     in.Model,
		Limit:     in.Limit,
		Force:     in.Force,
		Progress:  f.progress,
	})
	if err != nil {
		return awspkg.InferOutput{}, err
	}
	return awspkg.InferOutput{Out: out.Out, WorkDir: out.WorkDir, Files: out.Files}, nil
}
