package cmd

import (
	"fmt"
	"os"

	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/infra/models"
	"github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/internal/jsonnetaws"
	awspkg "github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/pkg/jsonnetaws"
	"github.com/marcbran/jsonnet-plugin-aws/services"
	jsonnetplugin "github.com/marcbran/jsonnet-plugin-jsonnet/jsonnet"
	"github.com/spf13/cobra"
)

var genCmd = &cobra.Command{
	Use:   "gen SERVICE",
	Short: "Generate arcourse nodes for an AWS service from its model, overrides, columns and links",
	Args:  cobra.ExactArgs(1),
	RunE:  runGen,
}

func init() {
	genCmd.Flags().String("inputs", "", "directory with resources.json, columns.json and links.json (default: ./SERVICE/inference)")
	genCmd.Flags().StringP("out", "o", "", "package directory main.libsonnet, pkg.libsonnet, mixins.libsonnet and jsonnetfile.json are written into (default: ./pkg/arcourse-aws-SERVICE)")
}

func runGen(cmd *cobra.Command, args []string) error {
	cmd.SilenceUsage = true
	cmd.SilenceErrors = true

	inputs, err := cmd.Flags().GetString("inputs")
	if err != nil {
		return err
	}
	out, err := cmd.Flags().GetString("out")
	if err != nil {
		return err
	}
	facade := jsonnetaws.NewFacade(models.NewLoader(services.All()...), nil, jsonnetplugin.Plugin())
	result, err := facade.Generate(cmd.Context(), awspkg.GenerateInput{Service: args[0], Inputs: inputs, Out: out})
	if err != nil {
		return err
	}
	for _, file := range result.Files {
		_, err = fmt.Fprintln(os.Stdout, file)
		if err != nil {
			return err
		}
	}
	return nil
}
