//go:build e2e

package tests

import "testing"

const iamPrelude = `
local aws = import 'main.libsonnet';
local ctx = import 'ctx.libsonnet';
local call(operation, input={}) = aws.call({ account: ctx.account }, 'iam', operation, input);
`

func TestIAMIsCalledWithoutRegion(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_user("/team/", "alice", nil).and().
		a_user("/team/", "bob", nil).and().
		a_user("/", "ci", nil)

	when.
		the_jsonnet_is_evaluated(iamPrelude + `
			local names(out) = std.sort([u.UserName for u in out.Users]);
			{
			  team: names(call('ListUsers', { PathPrefix: '/team/' })),
			  regional: names(aws.call(ctx, 'iam', 'ListUsers', {})),
			}
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"team": ["alice", "bob"], "regional": ["alice", "bob", "ci"]}`)
}

func TestIAMEncodesListMembers(t *testing.T) {
	_, when, then := scenario(t)

	when.
		the_jsonnet_is_evaluated(iamPrelude + `
			local policy(key) = std.manifestJsonMinified({
			  Version: '2012-10-17',
			  Statement: [{ Effect: 'Allow', Action: 's3:GetObject', Resource: '*', Condition: { StringEquals: { [key]: 'x' } } }],
			});
			local out = call('GetContextKeysForCustomPolicy', {
			  PolicyInputList: [policy('aws:SourceVpc'), policy('s3:prefix')],
			});
			std.sort(out.ContextKeyNames)
		`)

	then.
		there_is_no_error().and().
		the_output_is(`["aws:SourceVpc", "s3:prefix"]`)
}

func TestIAMDecodesMemberLists(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_user("/", "alice", map[string]string{"team": "search", "env": "dev"})

	when.
		the_jsonnet_is_evaluated(iamPrelude + `
			local tags = call('ListUserTags', { UserName: 'alice' });
			{ tags: { [t.Key]: t.Value for t in tags.Tags }, truncated: tags.IsTruncated }
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"tags": {"team": "search", "env": "dev"}, "truncated": false}`)
}

func TestIAMErrorsAreReturnedAsStatus(t *testing.T) {
	_, when, then := scenario(t)

	when.
		the_jsonnet_is_evaluated(iamPrelude + `
			local out = call('GetUser', { UserName: 'missing' });
			{ code: out.code, reason: out.reason }
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"code": 404, "reason": "NoSuchEntity"}`)
}
