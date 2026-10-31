models_ref := "1b9ff13fe6c28ea9774a527e53cda6a3b91369dc"

test-go:
    go test -v -cover -timeout=120s -parallel=10 ./...

test-jsonnet:
    jpoet test .

test: test-go test-jsonnet

lint-go:
    golangci-lint run ./...

lint: lint-go

build:
    jpoet pkg build
    rm -rf arcourse/build && jpoet pkg build arcourse
    for dir in services/*/arcourse/; do rm -rf "$dir/build" && jpoet pkg build "$dir" || exit 1; done

push: build
    jpoet pkg push
    jpoet pkg push arcourse
    for dir in services/*/arcourse/; do jpoet pkg push "$dir" || exit 1; done

update-models:
    #!/usr/bin/env bash
    set -euo pipefail
    for dir in services/*/; do
      svc=$(basename "$dir")
      version=$(gh api "repos/aws/api-models-aws/contents/models/$svc/service?ref={{models_ref}}" --jq '.[0].name')
      curl -fsSL -o "$dir/$svc.json" "https://raw.githubusercontent.com/aws/api-models-aws/{{models_ref}}/models/$svc/service/$version/$svc-$version.json"
    done

test-e2e:
    go test -v -tags e2e ./tests/...

ci: lint test build test-e2e

arcourse-gen service:
    go run ./cmd/jsonnet-aws gen "{{service}}" --inputs "services/{{service}}/inference" --out "services/{{service}}/arcourse"

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
