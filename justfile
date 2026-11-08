tool := "go tool -modfile=tools/go.mod"

models_ref := "1b9ff13fe6c28ea9774a527e53cda6a3b91369dc"

arcourse-gen service:
    go run ./cmd/jsonnet-aws gen "{{service}}" --inputs "services/{{service}}/inference" --out "pkg/arcourse-aws-{{service}}"

arcourse-infer service job:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{job}}" in
      resources|columns|links) ;;
      *) echo "unknown inference job: {{job}}; expected resources, columns or links" >&2; exit 1 ;;
    esac
    extra=()
    if [ -n "${LIMIT:-}" ]; then extra+=(--limit "$LIMIT"); fi
    if [ -n "${MODEL:-}" ]; then extra+=(--model "$MODEL"); fi
    if [ "${FORCE:-}" = "1" ]; then extra+=(--force); fi
    go run ./cmd/jsonnet-aws "{{job}}" infer "{{service}}" \
      --workdir "services/{{service}}/inference" \
      "${extra[@]+"${extra[@]}"}"

arcourse-infer-service service: (arcourse-infer service "resources") (arcourse-infer service "columns") (arcourse-infer service "links") (arcourse-gen service)

build-jsonnet: vendor-jsonnet
    for dir in pkg/*/; do \
        [ -f "$dir/main.libsonnet" ] || continue; \
        rm -rf "$dir/build" && {{tool}} jpoet pkg build -J "${dir}vendor" "$dir" || exit 1; \
    done

build: build-jsonnet

ci: lint vuln test build test-e2e

lint-go:
    {{tool}} golangci-lint run ./...

lint: lint-go

push-jsonnet: build-jsonnet
    for dir in pkg/*/; do \
        [ -f "$dir/main.libsonnet" ] || continue; \
        {{tool}} jpoet pkg push "$dir" || exit 1; \
    done

push: push-jsonnet

test-e2e:
    go test -v -tags e2e ./tests/...

test-go:
    go test -v -cover -timeout=120s -parallel=10 ./...

test-jsonnet: vendor-jsonnet
    for dir in pkg/*/; do \
        [ -f "$dir/main.libsonnet" ] || continue; \
        {{tool}} jpoet test -J "${dir}vendor" "$dir" || exit 1; \
    done

test: test-go test-jsonnet

update-models:
    #!/usr/bin/env bash
    set -euo pipefail
    for dir in services/*/; do
      svc=$(basename "$dir")
      version=$(gh api "repos/aws/api-models-aws/contents/models/$svc/service?ref={{models_ref}}" --jq '.[0].name')
      curl -fsSL -o "$dir/$svc.json" "https://raw.githubusercontent.com/aws/api-models-aws/{{models_ref}}/models/$svc/service/$version/$svc-$version.json"
    done

vendor-jsonnet:
    for dir in pkg/*/; do \
        [ -f "$dir/jsonnetfile.json" ] || continue; \
        (cd "$dir" && go tool -modfile=../../tools/go.mod jb install) || exit 1; \
    done

vuln-go:
    {{tool}} govulncheck ./...

vuln: vuln-go
