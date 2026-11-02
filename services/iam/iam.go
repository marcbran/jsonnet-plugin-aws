package iam

import (
	_ "embed"

	"github.com/marcbran/jsonnet-plugin-aws/aws"
)

//go:embed iam.json
var model []byte

var Service = aws.Definition{
	Model:          model,
	GlobalEndpoint: "https://iam.amazonaws.com",
}
