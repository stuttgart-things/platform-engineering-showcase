# Claim Machinery API – Docs & Examples

A simple API and CLI for discovering, validating, and rendering KCL-based Crossplane claim templates. Integrates with Backstage and supports OCI, YAML, and custom profiles.

## Why use it?
- **Browse & search** claim templates (KCL, Crossplane)
- **Validate** parameters and get schema info
- **Render** YAML with your own values
- **Integrate** with Backstage, CI/CD, or as a standalone tool

## Quick Examples

### Start API server
```bash
claim-machinery-api
# or
claim-machinery-api server
```

### List all templates
```bash
curl http://localhost:8080/api/v1/claim-templates
```

### Get template details
```bash
curl http://localhost:8080/api/v1/claim-templates/volumeclaim
```

### Render a claim (YAML output)
```bash
curl -X POST http://localhost:8080/api/v1/claim-templates/volumeclaim/order \
  -H "Content-Type: application/json" \
  -d '{"parameters": {"namespace": "production", "storage": "100Gi"}}' | jq -r '.rendered'
```

### Use interactive CLI
```bash
claim-machinery-api render
```

## Usage
- **Templates:** Load from local dir, profile YAML, or OCI URL
- **API:** REST endpoints for listing, details, rendering
- **CLI:** Interactive form, live YAML preview, validation
- **Config:** Flags or env vars for templates dir, profile, port

## More
- **Health:** `curl http://localhost:8080/health`
- **OpenAPI:** `curl http://localhost:8080/openapi.yaml` or open `/docs` in browser
- **Debug:** `DEBUG=1 claim-machinery-api`
- **CI/CD:** Dagger pipeline, Taskfile automation

## Files
- `main.go` – API/CLI entrypoint
- `internal/claimtemplate/` – Template logic
- `tests/` – Example templates and profiles

## Requirements
- Go >= 1.21
- KCL >= 0.7.x (for local rendering)

See the main README for full details and advanced usage.
