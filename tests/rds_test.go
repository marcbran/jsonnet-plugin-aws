//go:build e2e

package tests

import "testing"

const rdsPrelude = `
local aws = import 'main.libsonnet';
local ctx = import 'ctx.libsonnet';
local callIn(region, operation, input={}) = aws.call(ctx { region: region }, 'rds', operation, input);
`

func TestDescribeDBParameterGroupsPerRegion(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_db_parameter_group("eu-west-1", "pg15", "postgres15").and().
		a_db_parameter_group("eu-west-1", "mysql8", "mysql8.0").and().
		a_db_parameter_group("us-east-1", "pg16", "postgres16")

	when.
		the_jsonnet_is_evaluated(rdsPrelude + `
			local groups(region) = {
			  [g.DBParameterGroupName]: g.DBParameterGroupFamily
			  for g in callIn(region, 'DescribeDBParameterGroups').DBParameterGroups
			};
			{ euWest1: groups('eu-west-1'), usEast1: groups('us-east-1') }
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{
			"euWest1": {"pg15": "postgres15", "mysql8": "mysql8.0"},
			"usEast1": {"pg16": "postgres16"}
		}`)
}

func TestRDSErrorsAreReturnedAsStatus(t *testing.T) {
	_, when, then := scenario(t)

	when.
		the_jsonnet_is_evaluated(rdsPrelude + `
			local out = callIn('eu-west-1', 'DescribeDBInstances', { DBInstanceIdentifier: 'missing' });
			{ code: out._failure.code, reason: out._failure.reason }
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"code": 404, "reason": "DBInstanceNotFound"}`)
}
