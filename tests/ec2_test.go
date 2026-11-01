//go:build e2e

package tests

import "testing"

const ec2Prelude = `
local aws = import 'main.libsonnet';
local ctx = import 'ctx.libsonnet';
local call(operation, input={}) = aws.call(ctx, 'ec2', operation, input);
local name(resource) = [t.Value for t in resource.Tags if t.Key == 'Name'][0];
local byName(name) = { Filters: [{ Name: 'tag:Name', Values: [name] }] };
`

func TestDescribeVpcsByTagFilter(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_vpc("app", "10.0.0.0/16").and().
		a_vpc("data", "10.1.0.0/16")

	when.
		the_jsonnet_is_evaluated(ec2Prelude + `
			[{ name: name(vpc), cidr: vpc.CidrBlock } for vpc in call('DescribeVpcs', byName('app')).Vpcs]
		`)

	then.
		there_is_no_error().and().
		the_output_is(`[{"name": "app", "cidr": "10.0.0.0/16"}]`)
}

func TestDescribeVpcsByIdDecodesTypes(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_vpc("app", "10.0.0.0/16")

	when.
		the_jsonnet_is_evaluated(ec2Prelude + `
			local vpc = call('DescribeVpcs', byName('app')).Vpcs[0];
			local byId = call('DescribeVpcs', { VpcIds: [vpc.VpcId] }).Vpcs;
			{
			  found: [v.VpcId == vpc.VpcId for v in byId],
			  isDefault: vpc.IsDefault,
			  state: vpc.State,
			}
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"found": [true], "isDefault": false, "state": "available"}`)
}

func TestDescribeSubnetsOfVpc(t *testing.T) {
	given, when, then := scenario(t)

	given.
		a_vpc("app", "10.0.0.0/16").and().
		a_subnet("app", "app-a", "10.0.1.0/24").and().
		a_subnet("app", "app-b", "10.0.2.0/24").and().
		a_vpc("data", "10.1.0.0/16").and().
		a_subnet("data", "data-a", "10.1.1.0/24")

	when.
		the_jsonnet_is_evaluated(ec2Prelude + `
			local vpc = call('DescribeVpcs', byName('app')).Vpcs[0];
			local subnets = call('DescribeSubnets', { Filters: [{ Name: 'vpc-id', Values: [vpc.VpcId] }] }).Subnets;
			std.sort([
			  { name: name(s), cidr: s.CidrBlock, freeIsNumber: std.isNumber(s.AvailableIpAddressCount) }
			  for s in subnets
			], function(s) s.name)
		`)

	then.
		there_is_no_error().and().
		the_output_is(`[{"name": "app-a", "cidr": "10.0.1.0/24", "freeIsNumber": true}, {"name": "app-b", "cidr": "10.0.2.0/24", "freeIsNumber": true}]`)
}

func TestEC2ErrorIsReturnedAsStatus(t *testing.T) {
	_, when, then := scenario(t)

	when.
		the_jsonnet_is_evaluated(ec2Prelude + `
			local out = call('DescribeVpcs', { VpcIds: ['vpc-0000000000000000f'] });
			{ kind: out.kind, code: out.code, reason: out.reason }
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"kind": "Status", "code": 400, "reason": "InvalidVpcID.NotFound"}`)
}

func TestEC2DeniedOperation(t *testing.T) {
	_, when, then := scenario(t)

	when.
		the_jsonnet_is_evaluated(ec2Prelude + `
			local out = call('GetPasswordData', { InstanceId: 'i-0000000000000000f' });
			{ code: out.code, message: out.message }
		`)

	then.
		there_is_no_error().and().
		the_output_is(`{"code": 403, "message": "ec2 GetPasswordData is not an allowed read operation"}`)
}
