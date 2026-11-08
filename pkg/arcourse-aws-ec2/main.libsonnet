local a = import 'arcourse-ui/main.libsonnet',
      aws = import 'mixins.libsonnet',
      root = import 'root',
      call(ctx, operation, input) = std.native('invoke:aws')('call', [ctx, 'ec2', operation, input]);

[
  [['aws', '$account', '$region'], {
    links+: {
      EC2: root.aws.account($.account).region($.region).ec2,
    },
  }],
  [['aws', '$account', '$region', 'ec2']],
  [['aws', '$account', '$region', 'ec2', 'addresses'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeAddresses',
      {}
    ),
    data:: self.response,
    table:: {
      at: ['Addresses'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'publicIp', kind: 'identifier', label: 'Public IP', path: ['PublicIp'], priority: 'primary' },
        { key: 'allocationId', kind: 'identifier', label: 'Allocation ID', path: ['AllocationId'], priority: 'secondary' },
        { key: 'instanceId', kind: 'identifier', label: 'Instance ID', path: ['InstanceId'], priority: 'secondary' },
        { key: 'privateIpAddress', kind: 'identifier', label: 'Private IP', path: ['PrivateIpAddress'], priority: 'secondary' },
        { key: 'domain', kind: 'text', label: 'Domain', path: ['Domain'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['Addresses'],
        keys: [{ path: ['AllocationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'addresses' }, { param: 'AllocationId', path: ['AllocationId'] }],
      },
      {
        at: ['Addresses'],
        keys: [{ const: 'instance' }, { path: ['InstanceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'instances' }, { param: 'InstanceId', path: ['InstanceId'] }],
      },
      {
        at: ['Addresses'],
        keys: [{ const: 'network interface' }, { path: ['NetworkInterfaceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'networkInterfaces' }, { param: 'NetworkInterfaceId', path: ['NetworkInterfaceId'] }],
      },
      {
        at: ['Addresses'],
        keys: [{ const: 'subnet' }, { path: ['SubnetId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'addresses', '$AllocationId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['Addresses'],
    response:: call(
      self.ctx,
      'DescribeAddresses',
      {
        AllocationIds: [$.AllocationId],
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'instance' }, { path: ['InstanceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'instances' }, { param: 'InstanceId', path: ['InstanceId'] }],
      },
      {
        at: [],
        keys: [{ const: 'network interface' }, { path: ['NetworkInterfaceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'networkInterfaces' }, { param: 'NetworkInterfaceId', path: ['NetworkInterfaceId'] }],
      },
      {
        at: [],
        keys: [{ const: 'subnet' }, { path: ['SubnetId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'clientVpnEndpoints'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeClientVpnEndpoints',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['ClientVpnEndpoints'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'endpointId', kind: 'identifier', label: 'Endpoint ID', path: ['ClientVpnEndpointId'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status', 'Code'], priority: 'secondary' },
        { key: 'vpcId', kind: 'identifier', label: 'VPC ID', path: ['VpcId'], priority: 'secondary' },
        { key: 'clientCidrBlock', kind: 'text', label: 'Client CIDR', path: ['ClientCidrBlock'], priority: 'secondary' },
        { key: 'creationTime', kind: 'timestamp', label: 'Created', path: ['CreationTime'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['ClientVpnEndpoints'],
        keys: [{ path: ['ClientVpnEndpointId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'clientVpnEndpoints' }, { param: 'ClientVpnEndpointId', path: ['ClientVpnEndpointId'] }],
      },
      {
        at: ['ClientVpnEndpoints', 'AssociatedTargetNetworks'],
        keys: [{ const: 'subnet' }, { path: ['NetworkId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['NetworkId'] }],
      },
      {
        at: ['ClientVpnEndpoints', 'SecurityGroupIds'],
        keys: [{ const: 'security groups' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: [] }],
      },
      {
        at: ['ClientVpnEndpoints'],
        keys: [{ const: 'transit gateway attachment' }, { path: ['ClientVpnEndpointId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGatewayAttachments' }, { param: 'TransitGatewayAttachmentId', path: ['TransitGatewayConfiguration', 'TransitGatewayAttachmentId'] }],
      },
      {
        at: ['ClientVpnEndpoints'],
        keys: [{ const: 'transit gateway' }, { path: ['ClientVpnEndpointId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGateways' }, { param: 'TransitGatewayId', path: ['TransitGatewayConfiguration', 'TransitGatewayId'] }],
      },
      {
        at: ['ClientVpnEndpoints'],
        keys: [{ const: 'vpc' }, { path: ['ClientVpnEndpointId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'clientVpnEndpoints', '$ClientVpnEndpointId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['ClientVpnEndpoints'],
    response:: call(
      self.ctx,
      'DescribeClientVpnEndpoints',
      {
        ClientVpnEndpointIds: [$.ClientVpnEndpointId],
      }
    ),
    linkSpecs:: [
      {
        at: ['AssociatedTargetNetworks'],
        keys: [{ const: 'subnet' }, { path: ['NetworkId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['NetworkId'] }],
      },
      {
        at: ['SecurityGroupIds'],
        keys: [{ const: 'security groups' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: [] }],
      },
      {
        at: [],
        keys: [{ const: 'transit gateway attachment' }, { path: ['ClientVpnEndpointId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGatewayAttachments' }, { param: 'TransitGatewayAttachmentId', path: ['TransitGatewayConfiguration', 'TransitGatewayAttachmentId'] }],
      },
      {
        at: [],
        keys: [{ const: 'transit gateway' }, { path: ['ClientVpnEndpointId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGateways' }, { param: 'TransitGatewayId', path: ['TransitGatewayConfiguration', 'TransitGatewayId'] }],
      },
      {
        at: [],
        keys: [{ const: 'vpc' }, { path: ['ClientVpnEndpointId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'clientVpnEndpoints', '$ClientVpnEndpointId', 'clientVpnAuthorizationRules'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeClientVpnAuthorizationRules',
      self.page {
        ClientVpnEndpointId: $.ClientVpnEndpointId,
      }
    ),
    data:: self.response,
    table:: {
      at: ['AuthorizationRules'],
      columns: [
        { key: 'destinationCidr', kind: 'text', label: 'Destination CIDR', path: ['DestinationCidr'], priority: 'primary' },
        { key: 'groupId', kind: 'identifier', label: 'Group ID', path: ['GroupId'], priority: 'secondary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status', 'Code'], priority: 'secondary' },
        { key: 'accessAll', kind: 'boolean', label: 'Access All', path: ['AccessAll'], priority: 'secondary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'ec2', 'clientVpnEndpoints', '$ClientVpnEndpointId', 'clientVpnConnections'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeClientVpnConnections',
      self.page {
        ClientVpnEndpointId: $.ClientVpnEndpointId,
      }
    ),
    data:: self.response,
    table:: {
      at: ['Connections'],
      columns: [
        { key: 'username', kind: 'name', label: 'Username', path: ['Username'], priority: 'primary' },
        { key: 'connectionId', kind: 'identifier', label: 'Connection ID', path: ['ConnectionId'], priority: 'secondary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status', 'Code'], priority: 'secondary' },
        { key: 'clientIp', kind: 'text', label: 'Client IP', path: ['ClientIp'], priority: 'secondary' },
        { key: 'established', kind: 'timestamp', label: 'Established', path: ['ConnectionEstablishedTime'], priority: 'tertiary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'ec2', 'clientVpnEndpoints', '$ClientVpnEndpointId', 'clientVpnRoutes'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeClientVpnRoutes',
      self.page {
        ClientVpnEndpointId: $.ClientVpnEndpointId,
      }
    ),
    data:: self.response,
    table:: {
      at: ['Routes'],
      columns: [
        { key: 'destination', kind: 'text', label: 'Destination CIDR', path: ['DestinationCidr'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status', 'Code'], priority: 'secondary' },
        { key: 'target_subnet', kind: 'identifier', label: 'Target subnet', path: ['TargetSubnet'], priority: 'secondary' },
        { key: 'origin', kind: 'text', label: 'Origin', path: ['Origin'], priority: 'secondary' },
        { key: 'type', kind: 'text', label: 'Type', path: ['Type'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['Routes'],
        keys: [{ const: 'subnet' }, { path: ['TargetSubnet'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['TargetSubnet'] }],
      },
      {
        at: ['Routes'],
        keys: [{ const: 'transit gateway attachment' }, { path: ['TransitGatewayAttachmentId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGatewayAttachments' }, { param: 'TransitGatewayAttachmentId', path: ['TransitGatewayAttachmentId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'clientVpnEndpoints', '$ClientVpnEndpointId', 'clientVpnTargetNetworks'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeClientVpnTargetNetworks',
      self.page {
        ClientVpnEndpointId: $.ClientVpnEndpointId,
      }
    ),
    data:: self.response,
    table:: {
      at: ['ClientVpnTargetNetworks'],
      columns: [
        { key: 'targetNetworkId', kind: 'identifier', label: 'Target Network ID', path: ['TargetNetworkId'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status', 'Code'], priority: 'secondary' },
        { key: 'associationId', kind: 'identifier', label: 'Association ID', path: ['AssociationId'], priority: 'secondary' },
        { key: 'vpcId', kind: 'identifier', label: 'VPC ID', path: ['VpcId'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['ClientVpnTargetNetworks'],
        keys: [{ path: ['AssociationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'clientVpnEndpoints' }, { origin: 'ClientVpnEndpointId' }, { const: 'clientVpnTargetNetworks' }, { param: 'AssociationId', path: ['AssociationId'] }],
      },
      {
        at: ['ClientVpnTargetNetworks'],
        keys: [{ const: 'vpc' }, { path: ['AssociationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['ClientVpnTargetNetworks'],
        keys: [{ const: 'target subnet' }, { path: ['AssociationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['TargetNetworkId'] }],
      },
      {
        at: ['ClientVpnTargetNetworks', 'SecurityGroups'],
        keys: [{ const: 'security group' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: [] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'clientVpnEndpoints', '$ClientVpnEndpointId', 'clientVpnTargetNetworks', '$AssociationId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['ClientVpnTargetNetworks'],
    response:: call(
      self.ctx,
      'DescribeClientVpnTargetNetworks',
      {
        ClientVpnEndpointId: $.ClientVpnEndpointId,
        AssociationIds: [$.AssociationId],
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'vpc' }, { path: ['AssociationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: [],
        keys: [{ const: 'target subnet' }, { path: ['AssociationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['TargetNetworkId'] }],
      },
      {
        at: ['SecurityGroups'],
        keys: [{ const: 'security group' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: [] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'clientVpnEndpoints', '$ClientVpnEndpointId', 'authorizationPolicy'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'GetClientVpnEndpointAuthorizationPolicy',
      {
        ClientVpnEndpointId: $.ClientVpnEndpointId,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', '$region', 'ec2', 'customerGateways'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeCustomerGateways',
      {}
    ),
    data:: self.response,
    table:: {
      at: ['CustomerGateways'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'customerGatewayId', kind: 'identifier', label: 'Gateway ID', path: ['CustomerGatewayId'], priority: 'primary' },
        { key: 'deviceName', kind: 'name', label: 'Device name', path: ['DeviceName'], priority: 'secondary' },
        { key: 'state', kind: 'status', label: 'State', path: ['State'], priority: 'secondary' },
        { key: 'ipAddress', kind: 'text', label: 'IP address', path: ['IpAddress'], priority: 'secondary' },
        { key: 'type', kind: 'text', label: 'Type', path: ['Type'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['CustomerGateways'],
        keys: [{ path: ['CustomerGatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'customerGateways' }, { param: 'CustomerGatewayId', path: ['CustomerGatewayId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'customerGateways', '$CustomerGatewayId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['CustomerGateways'],
    response:: call(
      self.ctx,
      'DescribeCustomerGateways',
      {
        CustomerGatewayIds: [$.CustomerGatewayId],
      }
    ),
  }],
  [['aws', '$account', '$region', 'ec2', 'dhcpOptions'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeDhcpOptions',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['DhcpOptions'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'dhcpOptionsId', kind: 'identifier', label: 'DHCP options ID', path: ['DhcpOptionsId'], priority: 'primary' },
        { key: 'ownerId', kind: 'identifier', label: 'Owner ID', path: ['OwnerId'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['DhcpOptions'],
        keys: [{ path: ['DhcpOptionsId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'dhcpOptions' }, { param: 'DhcpOptionsId', path: ['DhcpOptionsId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'dhcpOptions', '$DhcpOptionsId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['DhcpOptions'],
    response:: call(
      self.ctx,
      'DescribeDhcpOptions',
      {
        DhcpOptionsIds: [$.DhcpOptionsId],
      }
    ),
  }],
  [['aws', '$account', '$region', 'ec2', 'egressOnlyInternetGateways'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeEgressOnlyInternetGateways',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['EgressOnlyInternetGateways'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'gatewayId', kind: 'identifier', label: 'Gateway ID', path: ['EgressOnlyInternetGatewayId'], priority: 'primary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['EgressOnlyInternetGateways'],
        keys: [{ path: ['EgressOnlyInternetGatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'egressOnlyInternetGateways' }, { param: 'EgressOnlyInternetGatewayId', path: ['EgressOnlyInternetGatewayId'] }],
      },
      {
        at: ['EgressOnlyInternetGateways', 'Attachments'],
        keys: [{ const: 'vpc' }, { path: ['VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'egressOnlyInternetGateways', '$EgressOnlyInternetGatewayId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['EgressOnlyInternetGateways'],
    response:: call(
      self.ctx,
      'DescribeEgressOnlyInternetGateways',
      {
        EgressOnlyInternetGatewayIds: [$.EgressOnlyInternetGatewayId],
      }
    ),
    linkSpecs:: [
      {
        at: ['Attachments'],
        keys: [{ const: 'vpc' }, { path: ['VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'instances'], a.table.node + aws.regional + aws.paginated + aws.flattened + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeInstances',
      self.page {
        IncludeManagedResources: std.get($._params, 'IncludeManagedResources', null),
      }
    ),
    itemsPath:: ['Reservations', 'Instances'],
    table:: {
      at: ['items'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'instanceId', kind: 'identifier', label: 'Instance ID', path: ['InstanceId'], priority: 'primary' },
        { key: 'state', kind: 'status', label: 'State', path: ['State', 'Name'], priority: 'secondary' },
        { key: 'instanceType', kind: 'text', label: 'Instance type', path: ['InstanceType'], priority: 'secondary' },
        { key: 'privateIp', kind: 'text', label: 'Private IP', path: ['PrivateIpAddress'], priority: 'secondary' },
        { key: 'availabilityZone', kind: 'text', label: 'Availability zone', path: ['Placement', 'AvailabilityZone'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['items'],
        keys: [{ path: ['InstanceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'instances' }, { param: 'InstanceId', path: ['InstanceId'] }],
      },
      {
        at: ['items', 'BlockDeviceMappings'],
        keys: [{ const: 'volumes' }, { path: ['DeviceName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'volumes' }, { param: 'VolumeId', path: ['Ebs', 'VolumeId'] }],
      },
      {
        at: ['items', 'NetworkInterfaces'],
        keys: [{ const: 'network interfaces' }, { path: ['NetworkInterfaceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'networkInterfaces' }, { param: 'NetworkInterfaceId', path: ['NetworkInterfaceId'] }],
      },
      {
        at: ['items', 'NetworkInterfaces', 'Groups'],
        keys: [{ const: 'network interface security groups' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['items', 'NetworkInterfaces'],
        keys: [{ const: 'network interface subnets' }, { path: ['NetworkInterfaceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: ['items', 'NetworkInterfaces'],
        keys: [{ const: 'network interface VPCs' }, { path: ['NetworkInterfaceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['items', 'SecurityGroups'],
        keys: [{ const: 'security groups' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['items'],
        keys: [{ const: 'subnet' }, { path: ['InstanceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: ['items'],
        keys: [{ const: 'VPC' }, { path: ['InstanceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'IncludeManagedResources', type: 'boolean' },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'instances', '$InstanceId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['Reservations', 'Instances'],
    response:: call(
      self.ctx,
      'DescribeInstances',
      {
        InstanceIds: [$.InstanceId],
      }
    ),
    linkSpecs:: [
      {
        at: ['BlockDeviceMappings'],
        keys: [{ const: 'volumes' }, { path: ['DeviceName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'volumes' }, { param: 'VolumeId', path: ['Ebs', 'VolumeId'] }],
      },
      {
        at: ['NetworkInterfaces'],
        keys: [{ const: 'network interfaces' }, { path: ['NetworkInterfaceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'networkInterfaces' }, { param: 'NetworkInterfaceId', path: ['NetworkInterfaceId'] }],
      },
      {
        at: ['NetworkInterfaces', 'Groups'],
        keys: [{ const: 'network interface security groups' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['NetworkInterfaces'],
        keys: [{ const: 'network interface subnets' }, { path: ['NetworkInterfaceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: ['NetworkInterfaces'],
        keys: [{ const: 'network interface VPCs' }, { path: ['NetworkInterfaceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['SecurityGroups'],
        keys: [{ const: 'security groups' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: [],
        keys: [{ const: 'subnet' }, { path: ['InstanceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: [],
        keys: [{ const: 'VPC' }, { path: ['InstanceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'instances', '$InstanceId', 'consoleOutput'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'GetConsoleOutput',
      {
        InstanceId: $.InstanceId,
        Latest: std.get($._params, 'Latest', null),
      }
    ),
    data: self.response,
    _paramSpecs+: [
      { default: null, name: 'Latest', type: 'boolean' },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'instances', '$InstanceId', 'consoleScreenshot'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'GetConsoleScreenshot',
      {
        InstanceId: $.InstanceId,
        WakeUp: std.get($._params, 'WakeUp', null),
      }
    ),
    data: self.response,
    _paramSpecs+: [
      { default: null, name: 'WakeUp', type: 'boolean' },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'instances', '$InstanceId', 'uefiData'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'GetInstanceUefiData',
      {
        InstanceId: $.InstanceId,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', '$region', 'ec2', 'instances', '$InstanceId', 'launchTemplateData'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'GetLaunchTemplateData',
      {
        InstanceId: $.InstanceId,
      }
    ),
    data: self.response,
    linkSpecs:: [
      {
        at: ['LaunchTemplateData'],
        keys: [{ const: 'key pair' }, { path: ['KeyName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'keyPairs' }, { param: 'KeyName', path: ['KeyName'] }],
      },
      {
        at: ['LaunchTemplateData', 'SecurityGroupIds'],
        keys: [{ const: 'security groups' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: [] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'internetGateways'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeInternetGateways',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['InternetGateways'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'internet_gateway_id', kind: 'identifier', label: 'Internet gateway ID', path: ['InternetGatewayId'], priority: 'primary' },
        { key: 'owner_id', kind: 'identifier', label: 'Owner ID', path: ['OwnerId'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['InternetGateways'],
        keys: [{ path: ['InternetGatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'internetGateways' }, { param: 'InternetGatewayId', path: ['InternetGatewayId'] }],
      },
      {
        at: ['InternetGateways', 'Attachments'],
        keys: [{ const: 'vpc' }, { path: ['VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'internetGateways', '$InternetGatewayId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['InternetGateways'],
    response:: call(
      self.ctx,
      'DescribeInternetGateways',
      {
        InternetGatewayIds: [$.InternetGatewayId],
      }
    ),
    linkSpecs:: [
      {
        at: ['Attachments'],
        keys: [{ const: 'vpc' }, { path: ['VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'keyPairs'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeKeyPairs',
      {
        IncludePublicKey: std.get($._params, 'IncludePublicKey', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['KeyPairs'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'key_name', kind: 'name', label: 'Key name', path: ['KeyName'], priority: 'primary' },
        { key: 'key_pair_id', kind: 'identifier', label: 'Key pair ID', path: ['KeyPairId'], priority: 'secondary' },
        { key: 'key_type', kind: 'text', label: 'Key type', path: ['KeyType'], priority: 'secondary' },
        { key: 'create_time', kind: 'timestamp', label: 'Created', path: ['CreateTime'], priority: 'tertiary' },
        { key: 'fingerprint', kind: 'text', label: 'Fingerprint', path: ['KeyFingerprint'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['KeyPairs'],
        keys: [{ path: ['KeyName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'keyPairs' }, { param: 'KeyName', path: ['KeyName'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'IncludePublicKey', type: 'boolean' },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'keyPairs', '$KeyName'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['KeyPairs'],
    response:: call(
      self.ctx,
      'DescribeKeyPairs',
      {
        KeyNames: [$.KeyName],
      }
    ),
  }],
  [['aws', '$account', '$region', 'ec2', 'launchTemplates'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeLaunchTemplates',
      self.page {
        IncludeManagedResources: std.get($._params, 'IncludeManagedResources', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['LaunchTemplates'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'LaunchTemplateName', kind: 'name', label: 'Launch template', path: ['LaunchTemplateName'], priority: 'primary' },
        { key: 'LaunchTemplateId', kind: 'identifier', label: 'Template ID', path: ['LaunchTemplateId'], priority: 'secondary' },
        { key: 'DefaultVersionNumber', kind: 'number', label: 'Default version', path: ['DefaultVersionNumber'], priority: 'secondary' },
        { key: 'LatestVersionNumber', kind: 'number', label: 'Latest version', path: ['LatestVersionNumber'], priority: 'secondary' },
        { key: 'CreateTime', kind: 'timestamp', label: 'Created', path: ['CreateTime'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['LaunchTemplates'],
        keys: [{ path: ['LaunchTemplateId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'launchTemplates' }, { param: 'LaunchTemplateId', path: ['LaunchTemplateId'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'IncludeManagedResources', type: 'boolean' },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'launchTemplates', '$LaunchTemplateId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['LaunchTemplates'],
    response:: call(
      self.ctx,
      'DescribeLaunchTemplates',
      {
        LaunchTemplateIds: [$.LaunchTemplateId],
      }
    ),
  }],
  [['aws', '$account', '$region', 'ec2', 'natGateways'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeNatGateways',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['NatGateways'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'nat_gateway_id', kind: 'identifier', label: 'NAT Gateway ID', path: ['NatGatewayId'], priority: 'primary' },
        { key: 'state', kind: 'status', label: 'State', path: ['State'], priority: 'secondary' },
        { key: 'connectivity_type', kind: 'text', label: 'Connectivity', path: ['ConnectivityType'], priority: 'secondary' },
        { key: 'subnet_id', kind: 'identifier', label: 'Subnet ID', path: ['SubnetId'], priority: 'secondary' },
        { key: 'vpc_id', kind: 'identifier', label: 'VPC ID', path: ['VpcId'], priority: 'secondary' },
        { key: 'create_time', kind: 'timestamp', label: 'Created', path: ['CreateTime'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['NatGateways'],
        keys: [{ path: ['NatGatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'natGateways' }, { param: 'NatGatewayId', path: ['NatGatewayId'] }],
      },
      {
        at: ['NatGateways', 'NatGatewayAddresses'],
        keys: [{ const: 'elastic IP' }, { path: ['AllocationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'addresses' }, { param: 'AllocationId', path: ['AllocationId'] }],
      },
      {
        at: ['NatGateways', 'NatGatewayAddresses'],
        keys: [{ const: 'network interface' }, { path: ['NetworkInterfaceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'networkInterfaces' }, { param: 'NetworkInterfaceId', path: ['NetworkInterfaceId'] }],
      },
      {
        at: ['NatGateways'],
        keys: [{ const: 'route table' }, { path: ['NatGatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'routeTables' }, { param: 'RouteTableId', path: ['RouteTableId'] }],
      },
      {
        at: ['NatGateways'],
        keys: [{ const: 'subnet' }, { path: ['NatGatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: ['NatGateways'],
        keys: [{ const: 'VPC' }, { path: ['NatGatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['NatGateways', 'AttachedAppliances'],
        keys: [{ const: 'VPC endpoint' }, { path: ['VpcEndpointId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcEndpoints' }, { param: 'VpcEndpointId', path: ['VpcEndpointId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'natGateways', '$NatGatewayId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['NatGateways'],
    response:: call(
      self.ctx,
      'DescribeNatGateways',
      {
        NatGatewayIds: [$.NatGatewayId],
      }
    ),
    linkSpecs:: [
      {
        at: ['NatGatewayAddresses'],
        keys: [{ const: 'elastic IP' }, { path: ['AllocationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'addresses' }, { param: 'AllocationId', path: ['AllocationId'] }],
      },
      {
        at: ['NatGatewayAddresses'],
        keys: [{ const: 'network interface' }, { path: ['NetworkInterfaceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'networkInterfaces' }, { param: 'NetworkInterfaceId', path: ['NetworkInterfaceId'] }],
      },
      {
        at: [],
        keys: [{ const: 'route table' }, { path: ['NatGatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'routeTables' }, { param: 'RouteTableId', path: ['RouteTableId'] }],
      },
      {
        at: [],
        keys: [{ const: 'subnet' }, { path: ['NatGatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: [],
        keys: [{ const: 'VPC' }, { path: ['NatGatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['AttachedAppliances'],
        keys: [{ const: 'VPC endpoint' }, { path: ['VpcEndpointId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcEndpoints' }, { param: 'VpcEndpointId', path: ['VpcEndpointId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'networkAcls'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeNetworkAcls',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['NetworkAcls'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'networkAclId', kind: 'identifier', label: 'Network ACL ID', path: ['NetworkAclId'], priority: 'primary' },
        { key: 'vpcId', kind: 'identifier', label: 'VPC ID', path: ['VpcId'], priority: 'secondary' },
        { key: 'isDefault', kind: 'boolean', label: 'Default', path: ['IsDefault'], priority: 'secondary' },
        { key: 'ownerId', kind: 'identifier', label: 'Owner ID', path: ['OwnerId'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['NetworkAcls'],
        keys: [{ path: ['NetworkAclId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'networkAcls' }, { param: 'NetworkAclId', path: ['NetworkAclId'] }],
      },
      {
        at: ['NetworkAcls'],
        keys: [{ const: 'vpc' }, { path: ['NetworkAclId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['NetworkAcls', 'Associations'],
        keys: [{ const: 'subnet' }, { path: ['NetworkAclAssociationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'networkAcls', '$NetworkAclId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['NetworkAcls'],
    response:: call(
      self.ctx,
      'DescribeNetworkAcls',
      {
        NetworkAclIds: [$.NetworkAclId],
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'vpc' }, { path: ['NetworkAclId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['Associations'],
        keys: [{ const: 'subnet' }, { path: ['NetworkAclAssociationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'networkInterfaces'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeNetworkInterfaces',
      self.page {
        IncludeManagedResources: std.get($._params, 'IncludeManagedResources', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['NetworkInterfaces'],
      columns: [
        { key: 'networkInterfaceId', kind: 'identifier', label: 'Network interface ID', path: ['NetworkInterfaceId'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status'], priority: 'secondary' },
        { key: 'privateIpAddress', kind: 'text', label: 'Private IP', path: ['PrivateIpAddress'], priority: 'secondary' },
        { key: 'subnetId', kind: 'identifier', label: 'Subnet ID', path: ['SubnetId'], priority: 'secondary' },
        { key: 'instanceId', kind: 'identifier', label: 'Instance ID', path: ['Attachment', 'InstanceId'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['NetworkInterfaces'],
        keys: [{ path: ['NetworkInterfaceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'networkInterfaces' }, { param: 'NetworkInterfaceId', path: ['NetworkInterfaceId'] }],
      },
      {
        at: ['NetworkInterfaces', 'Association'],
        keys: [{ const: 'elastic IP' }, { path: ['AllocationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'addresses' }, { param: 'AllocationId', path: ['AllocationId'] }],
      },
      {
        at: ['NetworkInterfaces', 'Attachment'],
        keys: [{ const: 'instance' }, { path: ['InstanceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'instances' }, { param: 'InstanceId', path: ['InstanceId'] }],
      },
      {
        at: ['NetworkInterfaces', 'Groups'],
        keys: [{ const: 'security group' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['NetworkInterfaces', 'AssociatedSubnets'],
        keys: [{ const: 'associated subnet' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: [] }],
      },
      {
        at: ['NetworkInterfaces'],
        keys: [{ const: 'subnet' }, { path: ['SubnetId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: ['NetworkInterfaces'],
        keys: [{ const: 'VPC' }, { path: ['VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['NetworkInterfaces', 'PrivateIpAddresses', 'Association'],
        keys: [{ const: 'elastic IP' }, { path: ['AllocationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'addresses' }, { param: 'AllocationId', path: ['AllocationId'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'IncludeManagedResources', type: 'boolean' },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'networkInterfaces', '$NetworkInterfaceId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['NetworkInterfaces'],
    response:: call(
      self.ctx,
      'DescribeNetworkInterfaces',
      {
        NetworkInterfaceIds: [$.NetworkInterfaceId],
      }
    ),
    linkSpecs:: [
      {
        at: ['Association'],
        keys: [{ const: 'elastic IP' }, { path: ['AllocationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'addresses' }, { param: 'AllocationId', path: ['AllocationId'] }],
      },
      {
        at: ['Attachment'],
        keys: [{ const: 'instance' }, { path: ['InstanceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'instances' }, { param: 'InstanceId', path: ['InstanceId'] }],
      },
      {
        at: ['Groups'],
        keys: [{ const: 'security group' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['AssociatedSubnets'],
        keys: [{ const: 'associated subnet' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: [] }],
      },
      {
        at: [],
        keys: [{ const: 'subnet' }, { path: ['SubnetId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: [],
        keys: [{ const: 'VPC' }, { path: ['VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['PrivateIpAddresses', 'Association'],
        keys: [{ const: 'elastic IP' }, { path: ['AllocationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'addresses' }, { param: 'AllocationId', path: ['AllocationId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'networkInterfaces', '$NetworkInterfaceId', 'attribute'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeNetworkInterfaceAttribute',
      {
        NetworkInterfaceId: $.NetworkInterfaceId,
        Attribute: std.get($._params, 'Attribute', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['Groups'],
      columns: [
        { key: 'groupName', kind: 'name', label: 'Group name', path: ['GroupName'], priority: 'primary' },
        { key: 'groupId', kind: 'identifier', label: 'Group ID', path: ['GroupId'], priority: 'secondary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'Attribute', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'routeTables'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeRouteTables',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['RouteTables'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'routeTableId', kind: 'identifier', label: 'Route table ID', path: ['RouteTableId'], priority: 'primary' },
        { key: 'vpcId', kind: 'identifier', label: 'VPC ID', path: ['VpcId'], priority: 'secondary' },
        { key: 'ownerId', kind: 'identifier', label: 'Owner ID', path: ['OwnerId'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['RouteTables'],
        keys: [{ path: ['RouteTableId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'routeTables' }, { param: 'RouteTableId', path: ['RouteTableId'] }],
      },
      {
        at: ['RouteTables'],
        keys: [{ const: 'vpc' }, { path: ['RouteTableId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['RouteTables', 'Associations'],
        keys: [{ const: 'subnet' }, { path: ['RouteTableAssociationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: ['RouteTables', 'PropagatingVgws'],
        keys: [{ const: 'VPN gateway' }, { path: ['GatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpnGateways' }, { param: 'VpnGatewayId', path: ['GatewayId'] }],
      },
      {
        at: ['RouteTables', 'Routes'],
        keys: [{ const: 'egress-only internet gateway' }, { path: ['DestinationCidrBlock'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'egressOnlyInternetGateways' }, { param: 'EgressOnlyInternetGatewayId', path: ['EgressOnlyInternetGatewayId'] }],
      },
      {
        at: ['RouteTables', 'Routes'],
        keys: [{ const: 'instance' }, { path: ['DestinationCidrBlock'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'instances' }, { param: 'InstanceId', path: ['InstanceId'] }],
      },
      {
        at: ['RouteTables', 'Routes'],
        keys: [{ const: 'NAT gateway' }, { path: ['DestinationCidrBlock'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'natGateways' }, { param: 'NatGatewayId', path: ['NatGatewayId'] }],
      },
      {
        at: ['RouteTables', 'Routes'],
        keys: [{ const: 'network interface' }, { path: ['DestinationCidrBlock'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'networkInterfaces' }, { param: 'NetworkInterfaceId', path: ['NetworkInterfaceId'] }],
      },
      {
        at: ['RouteTables', 'Routes'],
        keys: [{ const: 'transit gateway' }, { path: ['DestinationCidrBlock'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGateways' }, { param: 'TransitGatewayId', path: ['TransitGatewayId'] }],
      },
      {
        at: ['RouteTables', 'Routes'],
        keys: [{ const: 'VPC peering connection' }, { path: ['DestinationCidrBlock'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcPeeringConnections' }, { param: 'VpcPeeringConnectionId', path: ['VpcPeeringConnectionId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'routeTables', '$RouteTableId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['RouteTables'],
    response:: call(
      self.ctx,
      'DescribeRouteTables',
      {
        RouteTableIds: [$.RouteTableId],
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'vpc' }, { path: ['RouteTableId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['Associations'],
        keys: [{ const: 'subnet' }, { path: ['RouteTableAssociationId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: ['PropagatingVgws'],
        keys: [{ const: 'VPN gateway' }, { path: ['GatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpnGateways' }, { param: 'VpnGatewayId', path: ['GatewayId'] }],
      },
      {
        at: ['Routes'],
        keys: [{ const: 'egress-only internet gateway' }, { path: ['DestinationCidrBlock'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'egressOnlyInternetGateways' }, { param: 'EgressOnlyInternetGatewayId', path: ['EgressOnlyInternetGatewayId'] }],
      },
      {
        at: ['Routes'],
        keys: [{ const: 'instance' }, { path: ['DestinationCidrBlock'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'instances' }, { param: 'InstanceId', path: ['InstanceId'] }],
      },
      {
        at: ['Routes'],
        keys: [{ const: 'NAT gateway' }, { path: ['DestinationCidrBlock'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'natGateways' }, { param: 'NatGatewayId', path: ['NatGatewayId'] }],
      },
      {
        at: ['Routes'],
        keys: [{ const: 'network interface' }, { path: ['DestinationCidrBlock'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'networkInterfaces' }, { param: 'NetworkInterfaceId', path: ['NetworkInterfaceId'] }],
      },
      {
        at: ['Routes'],
        keys: [{ const: 'transit gateway' }, { path: ['DestinationCidrBlock'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGateways' }, { param: 'TransitGatewayId', path: ['TransitGatewayId'] }],
      },
      {
        at: ['Routes'],
        keys: [{ const: 'VPC peering connection' }, { path: ['DestinationCidrBlock'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcPeeringConnections' }, { param: 'VpcPeeringConnectionId', path: ['VpcPeeringConnectionId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'securityGroups'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeSecurityGroups',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['SecurityGroups'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'groupName', kind: 'name', label: 'Group name', path: ['GroupName'], priority: 'primary' },
        { key: 'groupId', kind: 'identifier', label: 'Group ID', path: ['GroupId'], priority: 'secondary' },
        { key: 'vpcId', kind: 'identifier', label: 'VPC ID', path: ['VpcId'], priority: 'secondary' },
        { key: 'ownerId', kind: 'identifier', label: 'Owner ID', path: ['OwnerId'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['SecurityGroups'],
        keys: [{ path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['SecurityGroups'],
        keys: [{ const: 'vpc' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['SecurityGroups', 'IpPermissions', 'UserIdGroupPairs'],
        keys: [{ const: 'referenced security group' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['SecurityGroups', 'IpPermissions', 'UserIdGroupPairs'],
        keys: [{ const: 'vpc' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['SecurityGroups', 'IpPermissions', 'UserIdGroupPairs'],
        keys: [{ const: 'VPC peering connection' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcPeeringConnections' }, { param: 'VpcPeeringConnectionId', path: ['VpcPeeringConnectionId'] }],
      },
      {
        at: ['SecurityGroups', 'IpPermissionsEgress', 'UserIdGroupPairs'],
        keys: [{ const: 'referenced security group (egress)' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['SecurityGroups', 'IpPermissionsEgress', 'UserIdGroupPairs'],
        keys: [{ const: 'vpc (egress)' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['SecurityGroups', 'IpPermissionsEgress', 'UserIdGroupPairs'],
        keys: [{ const: 'VPC peering connection (egress)' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcPeeringConnections' }, { param: 'VpcPeeringConnectionId', path: ['VpcPeeringConnectionId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'securityGroups', '$GroupId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['SecurityGroups'],
    response:: call(
      self.ctx,
      'DescribeSecurityGroups',
      {
        GroupIds: [$.GroupId],
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'vpc' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['IpPermissions', 'UserIdGroupPairs'],
        keys: [{ const: 'referenced security group' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['IpPermissions', 'UserIdGroupPairs'],
        keys: [{ const: 'vpc' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['IpPermissions', 'UserIdGroupPairs'],
        keys: [{ const: 'VPC peering connection' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcPeeringConnections' }, { param: 'VpcPeeringConnectionId', path: ['VpcPeeringConnectionId'] }],
      },
      {
        at: ['IpPermissionsEgress', 'UserIdGroupPairs'],
        keys: [{ const: 'referenced security group (egress)' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['IpPermissionsEgress', 'UserIdGroupPairs'],
        keys: [{ const: 'vpc (egress)' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['IpPermissionsEgress', 'UserIdGroupPairs'],
        keys: [{ const: 'VPC peering connection (egress)' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcPeeringConnections' }, { param: 'VpcPeeringConnectionId', path: ['VpcPeeringConnectionId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'securityGroups', '$GroupId', 'references'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeSecurityGroupReferences',
      {
        GroupId: $.GroupId,
      }
    ),
    data:: self.response,
    table:: {
      at: ['SecurityGroupReferenceSet'],
      columns: [
        { key: 'groupId', kind: 'identifier', label: 'Group ID', path: ['GroupId'], priority: 'primary' },
        { key: 'referencingVpcId', kind: 'identifier', label: 'Referencing VPC', path: ['ReferencingVpcId'], priority: 'secondary' },
        { key: 'transitGatewayId', kind: 'identifier', label: 'Transit Gateway', path: ['TransitGatewayId'], priority: 'secondary' },
        { key: 'vpcPeeringConnectionId', kind: 'identifier', label: 'Peering Connection', path: ['VpcPeeringConnectionId'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['SecurityGroupReferenceSet'],
        keys: [{ const: 'vpc' }, { path: ['ReferencingVpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['ReferencingVpcId'] }],
      },
      {
        at: ['SecurityGroupReferenceSet'],
        keys: [{ const: 'transit gateway' }, { path: ['TransitGatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGateways' }, { param: 'TransitGatewayId', path: ['TransitGatewayId'] }],
      },
      {
        at: ['SecurityGroupReferenceSet'],
        keys: [{ const: 'VPC peering connection' }, { path: ['VpcPeeringConnectionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcPeeringConnections' }, { param: 'VpcPeeringConnectionId', path: ['VpcPeeringConnectionId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'subnets'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeSubnets',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['Subnets'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'subnetId', kind: 'identifier', label: 'Subnet ID', path: ['SubnetId'], priority: 'primary' },
        { key: 'cidrBlock', kind: 'text', label: 'IPv4 CIDR', path: ['CidrBlock'], priority: 'secondary' },
        { key: 'availabilityZone', kind: 'text', label: 'Availability Zone', path: ['AvailabilityZone'], priority: 'secondary' },
        { key: 'state', kind: 'status', label: 'State', path: ['State'], priority: 'secondary' },
        { key: 'availableIpAddressCount', kind: 'count', label: 'Available IPs', path: ['AvailableIpAddressCount'], priority: 'secondary' },
        { key: 'vpcId', kind: 'identifier', label: 'VPC ID', path: ['VpcId'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['Subnets'],
        keys: [{ path: ['SubnetId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: ['Subnets'],
        keys: [{ const: 'vpc' }, { path: ['SubnetId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'subnets', '$SubnetId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['Subnets'],
    response:: call(
      self.ctx,
      'DescribeSubnets',
      {
        SubnetIds: [$.SubnetId],
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'vpc' }, { path: ['SubnetId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'subnets', '$SubnetId', 'cidrReservations'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'GetSubnetCidrReservations',
      {
        SubnetId: $.SubnetId,
        MaxResults: std.get($._params, 'MaxResults', null),
        NextToken: std.get($._params, 'NextToken', null),
      }
    ),
    data: self.response,
    _paramSpecs+: [
      { default: null, name: 'MaxResults', type: 'number' },
      { default: null, name: 'NextToken', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'transitGatewayAttachments'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeTransitGatewayAttachments',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['TransitGatewayAttachments'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'attachmentId', kind: 'identifier', label: 'Attachment ID', path: ['TransitGatewayAttachmentId'], priority: 'primary' },
        { key: 'resourceId', kind: 'identifier', label: 'Resource ID', path: ['ResourceId'], priority: 'secondary' },
        { key: 'resourceType', kind: 'text', label: 'Resource type', path: ['ResourceType'], priority: 'secondary' },
        { key: 'state', kind: 'status', label: 'State', path: ['State'], priority: 'secondary' },
        { key: 'transitGatewayId', kind: 'identifier', label: 'Transit gateway ID', path: ['TransitGatewayId'], priority: 'secondary' },
        { key: 'creationTime', kind: 'timestamp', label: 'Created', path: ['CreationTime'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['TransitGatewayAttachments'],
        keys: [{ path: ['TransitGatewayAttachmentId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGatewayAttachments' }, { param: 'TransitGatewayAttachmentId', path: ['TransitGatewayAttachmentId'] }],
      },
      {
        at: ['TransitGatewayAttachments'],
        keys: [{ const: 'transit gateway' }, { path: ['TransitGatewayAttachmentId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGateways' }, { param: 'TransitGatewayId', path: ['TransitGatewayId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'transitGatewayAttachments', '$TransitGatewayAttachmentId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['TransitGatewayAttachments'],
    response:: call(
      self.ctx,
      'DescribeTransitGatewayAttachments',
      {
        TransitGatewayAttachmentIds: [$.TransitGatewayAttachmentId],
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'transit gateway' }, { path: ['TransitGatewayAttachmentId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGateways' }, { param: 'TransitGatewayId', path: ['TransitGatewayId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'transitGatewayAttachments', '$TransitGatewayAttachmentId', 'propagations'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'GetTransitGatewayAttachmentPropagations',
      self.page {
        TransitGatewayAttachmentId: $.TransitGatewayAttachmentId,
      }
    ),
    data:: self.response,
    table:: {
      at: ['TransitGatewayAttachmentPropagations'],
      columns: [
        { key: 'transitGatewayRouteTableId', kind: 'identifier', label: 'Route table ID', path: ['TransitGatewayRouteTableId'], priority: 'primary' },
        { key: 'state', kind: 'status', label: 'State', path: ['State'], priority: 'secondary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'ec2', 'transitGatewayAttachments', '$TransitGatewayAttachmentId', 'natConfiguration'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'GetTransitGatewayAttachmentNatConfiguration',
      {
        TransitGatewayAttachmentId: $.TransitGatewayAttachmentId,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', '$region', 'ec2', 'transitGateways'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeTransitGateways',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['TransitGateways'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'transitGatewayId', kind: 'identifier', label: 'Transit Gateway ID', path: ['TransitGatewayId'], priority: 'primary' },
        { key: 'state', kind: 'status', label: 'State', path: ['State'], priority: 'secondary' },
        { key: 'creationTime', kind: 'timestamp', label: 'Created', path: ['CreationTime'], priority: 'secondary' },
        { key: 'amazonSideAsn', kind: 'number', label: 'Amazon-side ASN', path: ['Options', 'AmazonSideAsn'], priority: 'tertiary' },
        { key: 'dnsSupport', kind: 'boolean', label: 'DNS support', path: ['Options', 'DnsSupport'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['TransitGateways'],
        keys: [{ path: ['TransitGatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGateways' }, { param: 'TransitGatewayId', path: ['TransitGatewayId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'transitGateways', '$TransitGatewayId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['TransitGateways'],
    response:: call(
      self.ctx,
      'DescribeTransitGateways',
      {
        TransitGatewayIds: [$.TransitGatewayId],
      }
    ),
  }],
  [['aws', '$account', '$region', 'ec2', 'volumes'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeVolumes',
      self.page {
        IncludeManagedResources: std.get($._params, 'IncludeManagedResources', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['Volumes'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'volumeId', kind: 'identifier', label: 'Volume ID', path: ['VolumeId'], priority: 'primary' },
        { key: 'state', kind: 'status', label: 'State', path: ['State'], priority: 'secondary' },
        { key: 'size', kind: 'count', label: 'Size (GiB)', path: ['Size'], priority: 'secondary' },
        { key: 'volumeType', kind: 'text', label: 'Type', path: ['VolumeType'], priority: 'secondary' },
        { key: 'availabilityZone', kind: 'text', label: 'Availability Zone', path: ['AvailabilityZone'], priority: 'secondary' },
        { key: 'createTime', kind: 'timestamp', label: 'Created', path: ['CreateTime'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['Volumes'],
        keys: [{ path: ['VolumeId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'volumes' }, { param: 'VolumeId', path: ['VolumeId'] }],
      },
      {
        at: ['Volumes', 'Attachments'],
        keys: [{ const: 'attached instance' }, { path: ['VolumeId'] }, { path: ['InstanceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'instances' }, { param: 'InstanceId', path: ['InstanceId'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'IncludeManagedResources', type: 'boolean' },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'volumes', '$VolumeId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['Volumes'],
    response:: call(
      self.ctx,
      'DescribeVolumes',
      {
        VolumeIds: [$.VolumeId],
      }
    ),
    linkSpecs:: [
      {
        at: ['Attachments'],
        keys: [{ const: 'attached instance' }, { path: ['VolumeId'] }, { path: ['InstanceId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'instances' }, { param: 'InstanceId', path: ['InstanceId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'vpcEndpoints'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeVpcEndpoints',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['VpcEndpoints'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'vpcEndpointId', kind: 'identifier', label: 'Endpoint ID', path: ['VpcEndpointId'], priority: 'primary' },
        { key: 'serviceName', kind: 'name', label: 'Service', path: ['ServiceName'], priority: 'secondary' },
        { key: 'state', kind: 'status', label: 'State', path: ['State'], priority: 'secondary' },
        { key: 'vpcId', kind: 'identifier', label: 'VPC ID', path: ['VpcId'], priority: 'secondary' },
        { key: 'endpointType', kind: 'text', label: 'Type', path: ['VpcEndpointType'], priority: 'secondary' },
        { key: 'creationTimestamp', kind: 'timestamp', label: 'Created', path: ['CreationTimestamp'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['VpcEndpoints'],
        keys: [{ path: ['VpcEndpointId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcEndpoints' }, { param: 'VpcEndpointId', path: ['VpcEndpointId'] }],
      },
      {
        at: ['VpcEndpoints'],
        keys: [{ const: 'vpc' }, { path: ['VpcEndpointId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['VpcEndpoints', 'Groups'],
        keys: [{ const: 'security groups' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['VpcEndpoints', 'Ipv4Prefixes'],
        keys: [{ const: 'subnets' }, { path: ['SubnetId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: ['VpcEndpoints', 'Ipv6Prefixes'],
        keys: [{ const: 'subnets' }, { path: ['SubnetId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: ['VpcEndpoints', 'NetworkInterfaceIds'],
        keys: [{ const: 'network interfaces' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'networkInterfaces' }, { param: 'NetworkInterfaceId', path: [] }],
      },
      {
        at: ['VpcEndpoints', 'RouteTableIds'],
        keys: [{ const: 'route tables' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'routeTables' }, { param: 'RouteTableId', path: [] }],
      },
      {
        at: ['VpcEndpoints', 'SubnetIds'],
        keys: [{ const: 'subnets' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: [] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'vpcEndpoints', '$VpcEndpointId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['VpcEndpoints'],
    response:: call(
      self.ctx,
      'DescribeVpcEndpoints',
      {
        VpcEndpointIds: [$.VpcEndpointId],
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'vpc' }, { path: ['VpcEndpointId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['Groups'],
        keys: [{ const: 'security groups' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['Ipv4Prefixes'],
        keys: [{ const: 'subnets' }, { path: ['SubnetId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: ['Ipv6Prefixes'],
        keys: [{ const: 'subnets' }, { path: ['SubnetId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: ['SubnetId'] }],
      },
      {
        at: ['NetworkInterfaceIds'],
        keys: [{ const: 'network interfaces' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'networkInterfaces' }, { param: 'NetworkInterfaceId', path: [] }],
      },
      {
        at: ['RouteTableIds'],
        keys: [{ const: 'route tables' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'routeTables' }, { param: 'RouteTableId', path: [] }],
      },
      {
        at: ['SubnetIds'],
        keys: [{ const: 'subnets' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'subnets' }, { param: 'SubnetId', path: [] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'vpcPeeringConnections'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeVpcPeeringConnections',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['VpcPeeringConnections'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'connectionId', kind: 'identifier', label: 'Peering connection', path: ['VpcPeeringConnectionId'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status', 'Code'], priority: 'secondary' },
        { key: 'requesterVpc', kind: 'identifier', label: 'Requester VPC', path: ['RequesterVpcInfo', 'VpcId'], priority: 'secondary' },
        { key: 'accepterVpc', kind: 'identifier', label: 'Accepter VPC', path: ['AccepterVpcInfo', 'VpcId'], priority: 'secondary' },
        { key: 'expirationTime', kind: 'timestamp', label: 'Expires', path: ['ExpirationTime'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['VpcPeeringConnections'],
        keys: [{ path: ['VpcPeeringConnectionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcPeeringConnections' }, { param: 'VpcPeeringConnectionId', path: ['VpcPeeringConnectionId'] }],
      },
      {
        at: ['VpcPeeringConnections'],
        keys: [{ const: 'requester vpc' }, { path: ['VpcPeeringConnectionId'] }, { path: ['RequesterVpcInfo', 'VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['RequesterVpcInfo', 'VpcId'] }],
      },
      {
        at: ['VpcPeeringConnections'],
        keys: [{ const: 'accepter vpc' }, { path: ['VpcPeeringConnectionId'] }, { path: ['AccepterVpcInfo', 'VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['AccepterVpcInfo', 'VpcId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'vpcPeeringConnections', '$VpcPeeringConnectionId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['VpcPeeringConnections'],
    response:: call(
      self.ctx,
      'DescribeVpcPeeringConnections',
      {
        VpcPeeringConnectionIds: [$.VpcPeeringConnectionId],
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'requester vpc' }, { path: ['VpcPeeringConnectionId'] }, { path: ['RequesterVpcInfo', 'VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['RequesterVpcInfo', 'VpcId'] }],
      },
      {
        at: [],
        keys: [{ const: 'accepter vpc' }, { path: ['VpcPeeringConnectionId'] }, { path: ['AccepterVpcInfo', 'VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['AccepterVpcInfo', 'VpcId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'vpcs'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeVpcs',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['Vpcs'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'vpcId', kind: 'identifier', label: 'VPC ID', path: ['VpcId'], priority: 'primary' },
        { key: 'cidrBlock', kind: 'text', label: 'IPv4 CIDR', path: ['CidrBlock'], priority: 'secondary' },
        { key: 'state', kind: 'status', label: 'State', path: ['State'], priority: 'secondary' },
        { key: 'isDefault', kind: 'boolean', label: 'Default', path: ['IsDefault'], priority: 'secondary' },
        { key: 'instanceTenancy', kind: 'text', label: 'Tenancy', path: ['InstanceTenancy'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['Vpcs'],
        keys: [{ path: ['VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
      {
        at: ['Vpcs'],
        keys: [{ const: 'dhcp options' }, { path: ['VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'dhcpOptions' }, { param: 'DhcpOptionsId', path: ['DhcpOptionsId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'vpcs', '$VpcId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['Vpcs'],
    response:: call(
      self.ctx,
      'DescribeVpcs',
      {
        VpcIds: [$.VpcId],
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'dhcp options' }, { path: ['VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'dhcpOptions' }, { param: 'DhcpOptionsId', path: ['DhcpOptionsId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'vpcs', '$VpcId', 'securityGroupsForVpc'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'GetSecurityGroupsForVpc',
      self.page {
        VpcId: $.VpcId,
      }
    ),
    data:: self.response,
    table:: {
      at: ['SecurityGroupForVpcs'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'group_name', kind: 'name', label: 'Group name', path: ['GroupName'], priority: 'primary' },
        { key: 'group_id', kind: 'identifier', label: 'Group ID', path: ['GroupId'], priority: 'secondary' },
        { key: 'vpc_id', kind: 'identifier', label: 'VPC ID', path: ['PrimaryVpcId'], priority: 'secondary' },
        { key: 'owner_id', kind: 'identifier', label: 'Owner ID', path: ['OwnerId'], priority: 'tertiary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'ec2', 'vpcs', '$VpcId', 'staleSecurityGroups'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeStaleSecurityGroups',
      self.page {
        VpcId: $.VpcId,
      }
    ),
    data:: self.response,
    table:: {
      at: ['StaleSecurityGroupSet'],
      columns: [
        { key: 'groupName', kind: 'name', label: 'Group name', path: ['GroupName'], priority: 'primary' },
        { key: 'groupId', kind: 'identifier', label: 'Group ID', path: ['GroupId'], priority: 'secondary' },
        { key: 'vpcId', kind: 'identifier', label: 'VPC ID', path: ['VpcId'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['StaleSecurityGroupSet', 'StaleIpPermissions', 'UserIdGroupPairs'],
        keys: [{ const: 'security group' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['StaleSecurityGroupSet', 'StaleIpPermissions', 'UserIdGroupPairs'],
        keys: [{ const: 'VPC peering connection' }, { path: ['VpcPeeringConnectionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcPeeringConnections' }, { param: 'VpcPeeringConnectionId', path: ['VpcPeeringConnectionId'] }],
      },
      {
        at: ['StaleSecurityGroupSet', 'StaleIpPermissionsEgress', 'UserIdGroupPairs'],
        keys: [{ const: 'security group' }, { path: ['GroupId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'securityGroups' }, { param: 'GroupId', path: ['GroupId'] }],
      },
      {
        at: ['StaleSecurityGroupSet', 'StaleIpPermissionsEgress', 'UserIdGroupPairs'],
        keys: [{ const: 'VPC peering connection' }, { path: ['VpcPeeringConnectionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcPeeringConnections' }, { param: 'VpcPeeringConnectionId', path: ['VpcPeeringConnectionId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'vpcs', '$VpcId', 'resourcesBlockingEncryptionEnforcement'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'GetVpcResourcesBlockingEncryptionEnforcement',
      {
        VpcId: $.VpcId,
        MaxResults: std.get($._params, 'MaxResults', null),
        NextToken: std.get($._params, 'NextToken', null),
      }
    ),
    data: self.response,
    _paramSpecs+: [
      { default: null, name: 'MaxResults', type: 'number' },
      { default: null, name: 'NextToken', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'vpnConnections'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeVpnConnections',
      {}
    ),
    data:: self.response,
    table:: {
      at: ['VpnConnections'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'vpnConnectionId', kind: 'identifier', label: 'VPN connection ID', path: ['VpnConnectionId'], priority: 'primary' },
        { key: 'state', kind: 'status', label: 'State', path: ['State'], priority: 'secondary' },
        { key: 'customerGatewayId', kind: 'identifier', label: 'Customer gateway ID', path: ['CustomerGatewayId'], priority: 'secondary' },
        { key: 'vpnGatewayId', kind: 'identifier', label: 'VPN gateway ID', path: ['VpnGatewayId'], priority: 'secondary' },
        { key: 'transitGatewayId', kind: 'identifier', label: 'Transit gateway ID', path: ['TransitGatewayId'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['VpnConnections'],
        keys: [{ path: ['VpnConnectionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpnConnections' }, { param: 'VpnConnectionId', path: ['VpnConnectionId'] }],
      },
      {
        at: ['VpnConnections'],
        keys: [{ const: 'customer gateway' }, { path: ['VpnConnectionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'customerGateways' }, { param: 'CustomerGatewayId', path: ['CustomerGatewayId'] }],
      },
      {
        at: ['VpnConnections'],
        keys: [{ const: 'transit gateway' }, { path: ['VpnConnectionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGateways' }, { param: 'TransitGatewayId', path: ['TransitGatewayId'] }],
      },
      {
        at: ['VpnConnections'],
        keys: [{ const: 'VPN gateway' }, { path: ['VpnConnectionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpnGateways' }, { param: 'VpnGatewayId', path: ['VpnGatewayId'] }],
      },
      {
        at: ['VpnConnections'],
        keys: [{ const: 'transit gateway attachment' }, { path: ['VpnConnectionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGatewayAttachments' }, { param: 'TransitGatewayAttachmentId', path: ['Options', 'TransportTransitGatewayAttachmentId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'vpnConnections', '$VpnConnectionId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['VpnConnections'],
    response:: call(
      self.ctx,
      'DescribeVpnConnections',
      {
        VpnConnectionIds: [$.VpnConnectionId],
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'customer gateway' }, { path: ['VpnConnectionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'customerGateways' }, { param: 'CustomerGatewayId', path: ['CustomerGatewayId'] }],
      },
      {
        at: [],
        keys: [{ const: 'transit gateway' }, { path: ['VpnConnectionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGateways' }, { param: 'TransitGatewayId', path: ['TransitGatewayId'] }],
      },
      {
        at: [],
        keys: [{ const: 'VPN gateway' }, { path: ['VpnConnectionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpnGateways' }, { param: 'VpnGatewayId', path: ['VpnGatewayId'] }],
      },
      {
        at: [],
        keys: [{ const: 'transit gateway attachment' }, { path: ['VpnConnectionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'transitGatewayAttachments' }, { param: 'TransitGatewayAttachmentId', path: ['Options', 'TransportTransitGatewayAttachmentId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'vpnGateways'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeVpnGateways',
      {}
    ),
    data:: self.response,
    table:: {
      at: ['VpnGateways'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'vpnGatewayId', kind: 'identifier', label: 'VPN Gateway ID', path: ['VpnGatewayId'], priority: 'primary' },
        { key: 'state', kind: 'status', label: 'State', path: ['State'], priority: 'secondary' },
        { key: 'amazonSideAsn', kind: 'number', label: 'Amazon-side ASN', path: ['AmazonSideAsn'], priority: 'secondary' },
        { key: 'availabilityZone', kind: 'text', label: 'Availability zone', path: ['AvailabilityZone'], priority: 'tertiary' },
        { key: 'type', kind: 'text', label: 'Type', path: ['Type'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['VpnGateways'],
        keys: [{ path: ['VpnGatewayId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpnGateways' }, { param: 'VpnGatewayId', path: ['VpnGatewayId'] }],
      },
      {
        at: ['VpnGateways', 'VpcAttachments'],
        keys: [{ const: 'vpc' }, { path: ['VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ec2', 'vpnGateways', '$VpnGatewayId'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['VpnGateways'],
    response:: call(
      self.ctx,
      'DescribeVpnGateways',
      {
        VpnGatewayIds: [$.VpnGatewayId],
      }
    ),
    linkSpecs:: [
      {
        at: ['VpcAttachments'],
        keys: [{ const: 'vpc' }, { path: ['VpcId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ec2' }, { const: 'vpcs' }, { param: 'VpcId', path: ['VpcId'] }],
      },
    ],
  }],
]
