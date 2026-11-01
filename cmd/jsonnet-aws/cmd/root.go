package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var version = "dev"

var rootCmd = &cobra.Command{
	Use:   "jsonnet-aws",
	Short: "Infer resource overrides, links and columns from AWS Smithy models",
}

func init() {
	rootCmd.PersistentFlags().BoolP("quiet", "q", false, "Suppress progress messages on stderr")
	rootCmd.AddCommand(genCmd)
	rootCmd.AddCommand(resourcesCmd)
	rootCmd.AddCommand(columnsCmd)
	rootCmd.AddCommand(linksCmd)
	rootCmd.Version = version
}

func Execute() {
	err := rootCmd.Execute()
	if err == nil {
		return
	}
	fmt.Fprintln(os.Stderr, err)
	os.Exit(1)
}
