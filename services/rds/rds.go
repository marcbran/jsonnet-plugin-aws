package rds

import (
	_ "embed"

	"github.com/marcbran/jsonnet-plugin-aws/aws"
)

//go:embed rds.json
var model []byte

var Service = aws.Definition{
	Model: model,
}
