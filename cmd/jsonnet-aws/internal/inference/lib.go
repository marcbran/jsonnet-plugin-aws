package inference

import (
	"embed"
	"io/fs"
)

//go:embed lib
var lib embed.FS

func Lib() (fs.FS, error) {
	return fs.Sub(lib, "lib")
}
