package s3

import (
	_ "embed"

	"github.com/marcbran/jsonnet-plugin-aws/aws"
)

//go:embed s3.json
var model []byte

var Service = aws.Definition{
	Model: model,
}
