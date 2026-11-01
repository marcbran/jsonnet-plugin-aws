//go:build e2e

package tests

import (
	"context"
	"fmt"
	"os"
	"testing"

	"github.com/testcontainers/testcontainers-go"
)

func TestMain(m *testing.M) {
	container, err := startFloci(context.Background())
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		_ = testcontainers.TerminateContainer(container)
		os.Exit(1)
	}
	code := m.Run()
	err = testcontainers.TerminateContainer(container)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
	}
	os.Exit(code)
}
