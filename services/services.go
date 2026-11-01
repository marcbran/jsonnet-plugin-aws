package services

import (
	"github.com/marcbran/jsonnet-plugin-aws/aws"
	"github.com/marcbran/jsonnet-plugin-aws/services/ec2"
	"github.com/marcbran/jsonnet-plugin-aws/services/ecr"
)

func All() []aws.Definition {
	return []aws.Definition{ec2.Service, ecr.Service}
}
