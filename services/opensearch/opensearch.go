package opensearch

import (
	_ "embed"

	"github.com/marcbran/jsonnet-plugin-aws/aws"
)

//go:embed opensearch.json
var model []byte

var Service = aws.Definition{
	Model: model,
}
