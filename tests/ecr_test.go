//go:build e2e

package tests

import "testing"

const prelude = `
local aws = import 'main.libsonnet';
local ctx = import 'ctx.libsonnet';
local names(out) = std.sort([r.repositoryName for r in out.repositories]);
`

func TestDescribeRepositories(t *testing.T) {
	given, when, then := scenario(t)

	given.
		an_ecr_repository("app").and().
		an_ecr_repository("worker")

	when.
		the_jsonnet_is_evaluated(prelude + `
			names(aws.call(ctx, 'ecr', 'DescribeRepositories'))
		`)

	then.
		there_is_no_error().and().
		the_output_is(`["app", "worker"]`)
}

func TestDescribeRepositoriesByName(t *testing.T) {
	given, when, then := scenario(t)

	given.
		an_ecr_repository("app").and().
		an_ecr_repository("worker")

	when.
		the_jsonnet_is_evaluated(prelude + `
			names(aws.call(ctx, 'ecr', 'DescribeRepositories', { repositoryNames: ['worker'] }))
		`)

	then.
		there_is_no_error().and().
		the_output_is(`["worker"]`)
}

func TestDescribeRepositoriesNullInputMembers(t *testing.T) {
	given, when, then := scenario(t)

	given.
		an_ecr_repository("app")

	when.
		the_jsonnet_is_evaluated(prelude + `
			names(aws.call(ctx, 'ecr', 'DescribeRepositories', { nextToken: null, maxResults: null }))
		`)

	then.
		there_is_no_error().and().
		the_output_is(`["app"]`)
}

func TestTimestampsAreDecodedToDateTime(t *testing.T) {
	given, when, then := scenario(t)

	given.
		an_ecr_repository("app")

	when.
		the_jsonnet_is_evaluated(prelude + `
			local createdAt = aws.call(ctx, 'ecr', 'DescribeRepositories').repositories[0].createdAt;
			std.isString(createdAt) && std.endsWith(createdAt, 'Z') && std.length(std.findSubstr('T', createdAt)) == 1
		`)

	then.
		there_is_no_error().and().
		the_output_is(`true`)
}

func TestServiceErrorIsReturnedAsStatus(t *testing.T) {
	given, when, then := scenario(t)

	given.
		an_ecr_repository("app")

	when.
		the_jsonnet_is_evaluated(prelude + `
			local out = aws.call(ctx, 'ecr', 'DescribeImages', { repositoryName: 'missing' });
			{ code: out._failure.code, reason: out._failure.reason }
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"code": 400, "reason": "RepositoryNotFoundException"}`)
}

func TestRejectedCalls(t *testing.T) {
	cases := []struct {
		name      string
		operation string
		input     string
		expected  string
	}{
		{
			name:      "write operation",
			operation: "DeleteRepository",
			input:     `{ repositoryName: 'app' }`,
			expected:  `{"code": 403, "message": "ecr DeleteRepository is not an allowed read operation"}`,
		},
		{
			name:      "credential operation",
			operation: "GetAuthorizationToken",
			input:     `{}`,
			expected:  `{"code": 403, "message": "ecr GetAuthorizationToken is not an allowed read operation"}`,
		},
		{
			name:      "unknown operation",
			operation: "DescribeNothing",
			input:     `{}`,
			expected:  `{"code": 400, "message": "ecr has no operation DescribeNothing"}`,
		},
		{
			name:      "unknown input member",
			operation: "DescribeRepositories",
			input:     `{ bogus: 1 }`,
			expected:  `{"code": 400, "message": "ecr DescribeRepositories: DescribeRepositoriesRequest has no member bogus"}`,
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			given, when, then := scenario(t)

			given.
				an_ecr_repository("app")

			when.
				the_jsonnet_is_evaluated(prelude + `
					local out = aws.call(ctx, 'ecr', '` + tc.operation + `', ` + tc.input + `);
					{ code: out._failure.code, message: out._failure.message }
				`)

			then.
				there_is_no_error().and().
				the_output_is(tc.expected)
		})
	}
}

func TestAccountsAndRegionsAreSeparate(t *testing.T) {
	given, when, then := scenario(t)

	given.
		an_ecr_repository("app").and().
		an_ecr_repository_in_region("us-east-1", "jobs").and().
		an_ecr_repository_in_the_other_account("worker")

	when.
		the_jsonnet_is_evaluated(prelude + `
			local otherAccount = import 'other-account.libsonnet';
			{
			  account: names(aws.call(ctx, 'ecr', 'DescribeRepositories')),
			  otherRegion: names(aws.call(ctx { region: 'us-east-1' }, 'ecr', 'DescribeRepositories')),
			  otherAccount: names(aws.call(ctx { account: otherAccount }, 'ecr', 'DescribeRepositories')),
			  otherAccountAndRegion: names(aws.call({ account: otherAccount, region: 'us-east-1' }, 'ecr', 'DescribeRepositories')),
			}
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"account": ["app"], "otherRegion": ["jobs"], "otherAccount": ["worker"], "otherAccountAndRegion": []}`)
}
