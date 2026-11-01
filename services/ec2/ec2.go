package ec2

import (
	_ "embed"

	"github.com/marcbran/jsonnet-plugin-aws/aws"
)

//go:embed ec2.json
var model []byte

var Service = aws.Definition{
	Model:            model,
	DeniedOperations: []string{"GetPasswordData"},
}
