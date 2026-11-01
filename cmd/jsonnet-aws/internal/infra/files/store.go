package files

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// maxIDLen keeps result filenames under common filesystem component limits
// (e.g. 255 bytes on APFS/ext4) even for task IDs built by concatenating
// long, deeply nested API paths.
const maxIDLen = 150

type Store struct {
	workDir string
}

func NewStore(workDir string) *Store {
	return &Store{workDir: workDir}
}

func (s *Store) Load(jobName string, taskID string) ([]byte, bool, error) {
	path := s.resultPath(jobName, taskID)
	raw, err := os.ReadFile(path)
	if err == nil {
		return raw, true, nil
	}
	if os.IsNotExist(err) {
		return nil, false, nil
	}
	return nil, false, err
}

func (s *Store) Save(jobName string, taskID string, output []byte) error {
	path := s.resultPath(jobName, taskID)
	err := os.MkdirAll(filepath.Dir(path), 0755)
	if err != nil {
		return err
	}
	return os.WriteFile(path, bytes.TrimSpace(output), 0644)
}

func (s *Store) LoadAll(jobName string) (string, error) {
	resultsDir := filepath.Join(s.workDir, jobName, "results")
	err := os.MkdirAll(resultsDir, 0755)
	if err != nil {
		return "", err
	}
	files, err := filepath.Glob(filepath.Join(resultsDir, "*.json"))
	if err != nil {
		return "", err
	}
	sort.Strings(files)

	var imports strings.Builder
	imports.WriteString("[\n")
	var results strings.Builder
	results.WriteString("[\n")
	for _, file := range files {
		base := filepath.Base(file)
		fmt.Fprintf(&imports, "  import %q,\n", base)
		raw, err := os.ReadFile(file)
		if err != nil {
			return "", err
		}
		results.Write(bytes.TrimSpace(raw))
		results.WriteString(",\n")
	}
	imports.WriteString("]\n")
	results.WriteString("]\n")
	err = os.WriteFile(filepath.Join(resultsDir, "all.jsonnet"), []byte(imports.String()), 0644)
	if err != nil {
		return "", err
	}
	return results.String(), nil
}

func (s *Store) resultPath(jobName string, taskID string) string {
	return filepath.Join(s.workDir, jobName, "results", safeFilename(taskID)+".json")
}

// safeFilename shortens taskID if it's too long to be a filesystem path
// component, replacing the overflow with a content hash so the mapping
// stays deterministic and collision-resistant.
func safeFilename(id string) string {
	if len(id) <= maxIDLen {
		return id
	}
	sum := sha256.Sum256([]byte(id))
	hash := hex.EncodeToString(sum[:])[:16]
	return id[:maxIDLen-len(hash)-1] + "-" + hash
}
