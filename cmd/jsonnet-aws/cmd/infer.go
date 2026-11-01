package cmd

import (
	"context"
	"fmt"
	"os"

	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/infra/models"
	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/jsonnetaws"
	awspkg "github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/pkg/jsonnetaws"
	"github.com/marcbran/jsonnet-plugin-aws/services"
	"github.com/spf13/cobra"
)

type inferFunc func(f awspkg.Facade, ctx context.Context, in awspkg.InferInput) (awspkg.InferOutput, error)

func newInferCmd(kind string, short string, run inferFunc) *cobra.Command {
	parent := &cobra.Command{
		Use:   kind,
		Short: short,
	}
	infer := &cobra.Command{
		Use:   "infer SERVICE",
		Short: fmt.Sprintf("Infer %s for an AWS service model", kind),
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return runInfer(cmd, args[0], kind, run)
		},
	}
	infer.Flags().StringP("out", "o", "", fmt.Sprintf("output JSON file (default: <workdir>/%s.json)", kind))
	infer.Flags().String("workdir", "", "working directory for inference bundles and cached results (default: ./SERVICE)")
	infer.Flags().String("resources", "", "resource overrides applied to the tree (default: <workdir>/resources.json, if present)")
	infer.Flags().String("model", "", "Codex model to use for inference (default: the model configured in codex)")
	infer.Flags().Int("limit", 0, "maximum number of new Codex calls; 0 means unlimited")
	infer.Flags().Bool("force", false, "re-run Codex calls even when result files already exist")
	parent.AddCommand(infer)
	return parent
}

func runInfer(cmd *cobra.Command, service string, kind string, run inferFunc) error {
	cmd.SilenceUsage = true
	cmd.SilenceErrors = true

	in := awspkg.InferInput{Service: service}
	var err error
	in.Out, err = cmd.Flags().GetString("out")
	if err != nil {
		return err
	}
	in.WorkDir, err = cmd.Flags().GetString("workdir")
	if err != nil {
		return err
	}
	in.Resources, err = cmd.Flags().GetString("resources")
	if err != nil {
		return err
	}
	in.Model, err = cmd.Flags().GetString("model")
	if err != nil {
		return err
	}
	in.Limit, err = cmd.Flags().GetInt("limit")
	if err != nil {
		return err
	}
	in.Force, err = cmd.Flags().GetBool("force")
	if err != nil {
		return err
	}
	quiet, err := cmd.Flags().GetBool("quiet")
	if err != nil {
		return err
	}

	var progress func(jobName, taskID string, cached bool)
	if !quiet {
		_, err = fmt.Fprintf(os.Stderr, "inferring %s for %s\n", kind, service)
		if err != nil {
			return err
		}
		progress = func(jobName, taskID string, cached bool) {
			if cached {
				fmt.Fprintf(os.Stderr, "  [cached]  %s/%s\n", jobName, taskID)
			} else {
				fmt.Fprintf(os.Stderr, "  [running] %s/%s\n", jobName, taskID)
			}
		}
	}

	facade := jsonnetaws.NewFacade(models.NewLoader(services.All()...), progress)
	out, err := run(facade, cmd.Context(), in)
	if err != nil {
		return err
	}
	_, err = fmt.Fprintln(os.Stdout, out.Out)
	return err
}

var resourcesCmd = newInferCmd("resources", "Work with resource tree overrides", awspkg.Facade.InferResources)

var columnsCmd = newInferCmd("columns", "Work with table columns", awspkg.Facade.InferColumns)

var linksCmd = newInferCmd("links", "Work with links between resources", awspkg.Facade.InferLinks)
