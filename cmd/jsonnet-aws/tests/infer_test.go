//go:build e2e

package tests

import (
	"fmt"
	"testing"

	awspkg "github.com/marcbran/jsonnet-plugin-aws/cmd/jsonnet-aws/pkg/jsonnetaws"
)

const imagePlacement = `{"operation":"%s","decision":"place","collection":"DescribeImages","id":{"param":"imageDigest","path":["imageDigest"],"inputs":[{"path":["imageId","imageDigest"]}],"filter":{"member":"imageIds","itemPath":["imageDigest"]}},"confidence":"high","reason":"Image operations take the image digest as imageId."}`

const skip = `{"operation":"%s","decision":"skip","collection":null,"id":null,"confidence":"high","reason":"Not a child of any collection."}`

func TestResourcesInferWithCachedInference(t *testing.T) {
	given, when, then := scenario(t)

	given.
		the_service("ecr").and().
		a_cached_result("resources-inference", "DescribeImageScanFindings", fmt.Sprintf(imagePlacement, "DescribeImageScanFindings")).and().
		a_cached_result("resources-inference", "DescribeImageReplicationStatus", fmt.Sprintf(imagePlacement, "DescribeImageReplicationStatus")).and().
		a_cached_result("resources-inference", "DescribeImageSigningStatus", fmt.Sprintf(imagePlacement, "DescribeImageSigningStatus")).and().
		a_cached_result("resources-inference", "GetAccountSetting", fmt.Sprintf(skip, "GetAccountSetting")).and().
		a_cached_result("resources-inference", "ListImageReferrers", fmt.Sprintf(skip, "ListImageReferrers")).and().
		a_cached_result("resources-inference", "ListTagsForResource", fmt.Sprintf(skip, "ListTagsForResource")).and().
		a_cached_result("items-inference", "DescribeImageScanFindings", `{"operation":"DescribeImageScanFindings","decision":"list","items":["imageScanFindings","findings"],"confidence":"high","reason":"Basic scan findings are the primary records."}`)

	when.
		the_command_is_run(awspkg.Facade.InferResources)

	then.
		there_is_no_error().and().
		codex_was_not_called().and().
		the_output_matches("ecr/resources.json")
}

func TestResourcesInferKeepsExistingOverrides(t *testing.T) {
	given, when, then := scenario(t)

	given.
		the_service("ecr").and().
		the_resource_overrides("ecr/resources.json")

	when.
		the_command_is_run(awspkg.Facade.InferResources)

	then.
		there_is_no_error().and().
		codex_was_not_called_for("DescribeImageScanFindings", "DescribeImageReplicationStatus", "DescribeImageSigningStatus").and().
		the_output_matches("ecr/resources.json")
}

func TestColumnsInferWithCachedInference(t *testing.T) {
	given, when, then := scenario(t)

	given.
		the_service("ecr").and().
		the_resource_overrides("ecr/resources.json").and().
		the_output_file("columns.json").and().
		a_cached_result("columns-inference", "DescribeRepositories", `{"operation":"DescribeRepositories","array":["repositories"],"columns":[{"key":"repositoryName","path":["repositoryName"],"label":"Name","kind":"name","priority":"primary","reason":"Repositories are known by name."},{"key":"imageTagMutability","path":["imageTagMutability"],"label":"Tags","kind":"status","priority":"secondary","reason":"Mutability matters."},{"key":"createdAt","path":["createdAt"],"label":"Created","kind":"timestamp","priority":"tertiary","reason":"Recency."}],"confidence":"high","reason":"Scalar fields."}`)

	when.
		the_command_is_run(awspkg.Facade.InferColumns)

	then.
		the_error_mentions("columns-inference/DescribeRepositoryCreationTemplates").and().
		no_result_is_cached("columns-inference", "DescribeRepositoryCreationTemplates").and().
		codex_was_not_called_for("DescribeRepositories").and().
		the_output_matches("ecr/columns.json")
}

func TestLinksInferWithCachedInference(t *testing.T) {
	given, when, then := scenario(t)

	given.
		the_service("ecr").and().
		the_resource_overrides("ecr/resources.json").and().
		a_cached_result("links-inference", "GetRepositoryPolicy", `{"operation":"GetRepositoryPolicy","links":[{"at":[],"keys":[{"const":"repository","path":null}],"target":"DescribeRepositories","vars":[{"param":"repositoryName","path":["repositoryName"]}],"confidence":"high","reason":"Ancestor, covered by breadcrumbs."}]}`).and().
		a_cached_result("links-inference", "DescribePullThroughCacheRules", `{"operation":"DescribePullThroughCacheRules","links":[{"at":["pullThroughCacheRules"],"keys":[{"const":"upstream repository","path":null},{"const":null,"path":["upstreamRepositoryPrefix"]}],"target":"DescribeRepositories","vars":[{"param":"repositoryName","path":["upstreamRepositoryPrefix"]}],"confidence":"low","reason":"Example."}]}`)

	when.
		the_command_is_run(awspkg.Facade.InferLinks)

	then.
		there_is_no_error().and().
		codex_was_not_called_for("DescribePullThroughCacheRules", "GetRepositoryPolicy").and().
		the_output_matches("ecr/links.json")
}
