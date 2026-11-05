//go:build e2e

package tests

import "testing"

const s3Prelude = `
local aws = import 'main.libsonnet';
local ctx = import 'ctx.libsonnet';
local call(operation, input={}) = aws.call(ctx, 's3', operation, input);
`

func TestListBucketsReportsRegions(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_bucket("eu-west-1", "logs").and().
		a_bucket("eu-west-1", "assets").and().
		a_bucket("us-east-1", "backups")

	when.
		the_jsonnet_is_evaluated(s3Prelude + `
			local buckets = call('ListBuckets', { BucketRegion: 'eu-west-1' }).Buckets;
			{ [b.Name]: b.BucketRegion for b in buckets }
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"assets": "eu-west-1", "logs": "eu-west-1", "backups": "us-east-1"}`)
}

func TestListObjectsWithPrefixAndDelimiter(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_bucket("eu-west-1", "logs").and().
		an_object("logs", "app/2026/a.log", "a").and().
		an_object("logs", "app/2026/b.log", "bb").and().
		an_object("logs", "web/c.log", "ccc").and().
		an_object("logs", "readme.md", "dddd")

	when.
		the_jsonnet_is_evaluated(s3Prelude + `
			local nested = call('ListObjectsV2', { Bucket: 'logs', Prefix: 'app/' });
			local top = call('ListObjectsV2', { Bucket: 'logs', Delimiter: '/' });
			{
			  nested: [{ key: o.Key, size: o.Size } for o in nested.Contents],
			  files: [o.Key for o in top.Contents],
			  folders: [p.Prefix for p in top.CommonPrefixes],
			}
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{
			"nested": [{"key": "app/2026/a.log", "size": 1}, {"key": "app/2026/b.log", "size": 2}],
			"files": ["readme.md"],
			"folders": ["app/", "web/"]
		}`)
}

func TestHeadObjectDecodesHeaders(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_bucket("eu-west-1", "logs").and().
		an_object("logs", "app/2026/a.log", "hello").and().
		an_object("logs", "app/a+b:c@d e=f.log", "special")

	when.
		the_jsonnet_is_evaluated(s3Prelude + `
			local head = call('HeadObject', { Bucket: 'logs', Key: 'app/2026/a.log' });
			{
			  length: head.ContentLength,
			  type: head.ContentType,
			  modified: std.isString(head.LastModified) && std.endsWith(head.LastModified, 'Z'),
			  special: call('HeadObject', { Bucket: 'logs', Key: 'app/a+b:c@d e=f.log' }).ContentLength,
			}
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"length": 5, "type": "text/plain", "modified": true, "special": 7}`)
}

func TestBucketPolicyPayloadAndLocation(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_bucket("eu-west-1", "logs").and().
		a_bucket_policy("logs", `{"Version":"2012-10-17","Statement":[{"Effect":"Deny","Principal":"*","Action":"s3:DeleteBucket","Resource":"arn:aws:s3:::logs"}]}`)

	when.
		the_jsonnet_is_evaluated(s3Prelude + `
			{
			  effect: std.parseJson(call('GetBucketPolicy', { Bucket: 'logs' }).Policy).Statement[0].Effect,
			  location: call('GetBucketLocation', { Bucket: 'logs' }).LocationConstraint,
			  granteeTypes: [g.Grantee.Type for g in call('GetBucketAcl', { Bucket: 'logs' }).Grants],
			}
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"effect": "Deny", "location": "eu-west-1", "granteeTypes": ["CanonicalUser"]}`)
}

func TestS3ErrorsAreReturnedAsStatus(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_bucket("eu-west-1", "logs")

	when.
		the_jsonnet_is_evaluated(s3Prelude + `
			local status(out) = { code: out._failure.code, reason: out._failure.reason };
			{
			  notConfigured: status(call('GetBucketPolicy', { Bucket: 'logs' })),
			  missingBucket: status(call('ListObjectsV2', { Bucket: 'missing' })),
			  download: status(call('GetObject', { Bucket: 'logs', Key: 'a' })),
			}
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{
			"notConfigured": {"code": 404, "reason": "NoSuchBucketPolicy"},
			"missingBucket": {"code": 404, "reason": "NoSuchBucket"},
			"download": {"code": 403, "reason": "Forbidden"}
		}`)
}
