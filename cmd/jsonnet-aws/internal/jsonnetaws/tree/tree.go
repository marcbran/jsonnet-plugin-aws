package tree

import (
	"embed"
	"io/fs"
)

//go:embed *.libsonnet
var lib embed.FS

func FS() fs.FS {
	return lib
}
