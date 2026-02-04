# claims – Summary

A CLI tool for rendering and managing Crossplane claim templates via the claim-machinery API. Designed for both interactive use and automation (CI/CD, GitOps).

## What does it do?
- **Render claim templates** (YAML) from KCL/Crossplane sources
- **Interactively** select templates and fill parameters, or run fully automated
- **Validate** parameters and preview output before saving
- **Save** rendered manifests to files (single or multiple)
- **Integrate with GitOps:** auto-commit, push, and create pull requests

## How to use (examples)

### Interactive rendering
```bash
claims render
```

### Non-interactive (CI/CD)
```bash
claims render --non-interactive -t volumeclaim-simple -p name=my-volume -o ./out
```

### Batch rendering with params file
```bash
claims render --non-interactive -f params.yaml -o ./out
```

### GitOps: commit and push
```bash
claims render --non-interactive -t volumeclaim-simple -p name=my-volume -o ./out --git-push
```

## Requirements
- Go >= 1.25.5
- claim-machinery API running (default: http://localhost:8080)

See the main README for all options, flags, and advanced workflows.
