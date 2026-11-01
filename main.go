package main

import (
	"github.com/marcbran/jsonnet-plugin-aws/aws"
	"github.com/marcbran/jsonnet-plugin-aws/services"
)

func main() {
	aws.Plugin(aws.WithServices(services.All()...)).Serve()
}
