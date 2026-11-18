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
		a_cached_result("links-inference", "DescribeRepositories", `{"operation":"DescribeRepositories","links":[{"at":["repositories"],"keys":[{"const":"itself","path":null}],"target":"DescribeRepositories","vars":[{"param":"repositoryName","path":["repositoryName"]}],"confidence":"high","reason":"Self-link, covered by the row link."}]}`).and().
		a_cached_result("links-inference", "GetRepositoryPolicy", `{"operation":"GetRepositoryPolicy","links":[{"at":[],"keys":[{"const":"repository","path":null}],"target":"DescribeRepositories","vars":[{"param":"repositoryName","path":["repositoryName"]}],"confidence":"high","reason":"Ancestor, covered by breadcrumbs."}]}`).and().
		a_cached_result("links-inference", "DescribePullThroughCacheRules", `{"operation":"DescribePullThroughCacheRules","links":[{"at":["pullThroughCacheRules"],"keys":[{"const":"upstream repository","path":null},{"const":null,"path":["upstreamRepositoryPrefix"]}],"target":"DescribeRepositories","vars":[{"param":"repositoryName","path":["upstreamRepositoryPrefix"]}],"confidence":"low","reason":"Example."}]}`)

	when.
		the_command_is_run(awspkg.Facade.InferLinks)

	then.
		there_is_no_error().and().
		codex_was_not_called_for("DescribePullThroughCacheRules", "GetRepositoryPolicy", "DescribeRepositories").and().
		the_output_matches("ecr/links.json")
}

func TestParamsInferWithCachedInference(t *testing.T) {
	given, when, then := scenario(t)

	given.
		the_service("ecr").and().
		the_resource_overrides("ecr/resources.json").and().
		the_output_file("params.json").and().
		a_cached_result("params-inference", "DescribePullThroughCacheRules", `{"confidence":"high","operation":"DescribePullThroughCacheRules","params":[{"name":"ecrRepositoryPrefixes","reason":"Restricts results to rules associated with the specified repository prefixes.","role":"filter"}],"reason":"The documentation says the prefixes select which rules are returned."}`).and().
		a_cached_result("params-inference", "DescribeReplicationBackfillResults", `{"confidence":"high","operation":"DescribeReplicationBackfillResults","params":[{"name":"resultStatusFilter","reason":"Filters returned results by status.","role":"filter"}],"reason":"The documentation explicitly says this parameter filters the returned results."}`).and().
		a_cached_result("params-inference", "DescribeRepositories", `{"confidence":"high","operation":"DescribeRepositories","params":[{"name":"repositoryNames","reason":"Restricts the response to the named repositories.","role":"filter"}],"reason":"repositoryNames selects which repositories are described."}`).and().
		a_cached_result("params-inference", "DescribeRepositoryCreationTemplates", `{"confidence":"high","operation":"DescribeRepositoryCreationTemplates","params":[{"name":"prefixes","reason":"Limits results to templates associated with the specified repository namespace prefixes.","role":"filter"}],"reason":"The documentation says that specifying prefixes returns matching templates; otherwise all templates are returned."}`).and().
		a_cached_result("params-inference", "ListPullTimeUpdateExclusions", `{"confidence":"high","operation":"ListPullTimeUpdateExclusions","params":[{"name":"maxResults","reason":"Limits the number of results returned per page.","role":"pagination"},{"name":"nextToken","reason":"Continues listing from the previous page.","role":"pagination"}],"reason":"Both parameters control paginated results."}`)

	when.
		the_command_is_run(awspkg.Facade.InferParams)

	then.
		the_error_mentions("params-inference/DescribeImages").and().
		no_result_is_cached("params-inference", "DescribeImages").and().
		codex_was_not_called_for("DescribeRepositories", "ListPullTimeUpdateExclusions").and().
		the_output_matches("ecr/params.json")
}
