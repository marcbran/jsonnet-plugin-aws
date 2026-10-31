package ecr

import (
	_ "embed"

	"github.com/marcbran/jsonnet-plugin-aws/aws"
)

//go:embed ecr.json
var model []byte

var Service = aws.Definition{
	Model:            model,
	DeniedOperations: []string{"GetAuthorizationToken", "GetDownloadUrlForLayer"},
}
