package main

import (
	"context"
	"dagger/postgresdb/internal/dagger"
	"fmt"
	"strings"
)

type Postgresdb struct{}

func (m *Postgresdb) RunPrCheck(
	ctx context.Context,
	source *dagger.Directory,
	// headRef is the reference to compare against, typically the main branch
	// +optional
	// +default=HEAD
	headRef string,
	// baseRef is the reference to compare against, typically the main branch
	// +optional
	// +default=origin/main
	baseRef string,
	policy *dagger.Directory,
) error {
	// Step 1: Get all changed files
	changedFiles, err := m.GetChangedFiles(ctx, source, headRef, baseRef)
	if err != nil {
		return fmt.Errorf("failed to get changed files: %w", err)
	}

	// Step 2: Filter files under crossplane/postgres-db/
	var relevantFiles []string
	for _, file := range changedFiles {
		if strings.HasPrefix(file, "crossplane/postgres-db/") {
			// Optional: filter out known non-Kubernetes files
			if strings.HasSuffix(file, "catalog-info.yaml") {
				continue
			}
			relevantFiles = append(relevantFiles, file)
		}
	}

	if len(relevantFiles) == 0 {
		fmt.Println("✅ No changes in crossplane/postgres-db/, skipping policy check")
		return nil
	}

	// Step 3: Create a new Directory with only relevant files
	filtered := dag.Directory()
	for i, file := range relevantFiles {
		// Extract filename only
		fileName := fmt.Sprintf("resource-%d.yaml", i)
		filtered = filtered.WithFile(fileName, source.File(file))
		fmt.Printf("📝 Loading %s as %s\n", file, fileName)
	}
	// Step 4: Run Kyverno validation on filtered directory
	return m.KyvernoValidation(ctx, policy, filtered)
}

func (m *Postgresdb) GetChangedFiles(
	ctx context.Context,
	source *dagger.Directory,
	// +optional
	// +default=HEAD
	headRef string,
	// +optional
	// +default=origin/main
	baseRef string,
) ([]string, error) {
	return dag.GitFilesChanged().Files(
		ctx,
		source,
		dagger.GitFilesChangedFilesOpts{
			HeadRef: headRef,
			BaseRef: baseRef,
		},
	)
}

func (m *Postgresdb) KyvernoValidation(
	ctx context.Context,
	policy *dagger.Directory,
	resource *dagger.Directory,
) error {
	return dag.Kyverno().Validate(
		ctx,
		policy,
		resource,
	)
}
