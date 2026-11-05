//go:build e2e

package tests

import "testing"

const opensearchPrelude = `
local aws = import 'main.libsonnet';
local ctx = import 'ctx.libsonnet';
local call(operation, input={}) = aws.call(ctx, 'opensearch', operation, input);
local callIn(region, operation, input={}) = aws.call(ctx { region: region }, 'opensearch', operation, input);
`

func TestListDomainNamesPerRegion(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_domain("eu-west-1", "search", "OpenSearch_2.11").and().
		a_domain("eu-west-1", "logs", "OpenSearch_2.11").and().
		a_domain("us-east-1", "audit", "OpenSearch_2.11")

	when.
		the_jsonnet_is_evaluated(opensearchPrelude + `
			local names(region) = std.sort([d.DomainName for d in callIn(region, 'ListDomainNames').DomainNames]);
			{ euWest1: names('eu-west-1'), usEast1: names('us-east-1') }
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"euWest1": ["logs", "search"], "usEast1": ["audit"]}`)
}

func TestDescribeDomainBindsLabel(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_domain("eu-west-1", "search", "OpenSearch_2.11")

	when.
		the_jsonnet_is_evaluated(opensearchPrelude + `
			local domain = call('DescribeDomain', { DomainName: 'search' }).DomainStatus;
			{ name: domain.DomainName, version: domain.EngineVersion, instances: domain.ClusterConfig.InstanceCount }
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"name": "search", "version": "OpenSearch_2.11", "instances": 1}`)
}

func TestDescribeDomainsSendsJSONBody(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_domain("eu-west-1", "search", "OpenSearch_2.11").and().
		a_domain("eu-west-1", "logs", "OpenSearch_1.3")

	when.
		the_jsonnet_is_evaluated(opensearchPrelude + `
			local domains = call('DescribeDomains', { DomainNames: ['search', 'logs'] }).DomainStatusList;
			{ [d.DomainName]: d.EngineVersion for d in domains }
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"search": "OpenSearch_2.11", "logs": "OpenSearch_1.3"}`)
}

func TestListVersionsBindsQuery(t *testing.T) {
	_, when, then := scenario(t)

	when.
		the_jsonnet_is_evaluated(opensearchPrelude + `
			local versions = call('ListVersions', { MaxResults: 50 }).Versions;
			std.member(versions, 'OpenSearch_2.11')
		`)

	then.
		there_is_no_error().and().
		the_output_is(`true`)
}

func TestOpenSearchErrorsAreReturnedAsStatus(t *testing.T) {
	_, when, then := scenario(t)

	when.
		the_jsonnet_is_evaluated(opensearchPrelude + `
			local out = call('DescribeDomain', { DomainName: 'missing' });
			{ code: out._failure.code, reason: out._failure.reason }
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"code": 409, "reason": "ResourceNotFoundException"}`)
}
