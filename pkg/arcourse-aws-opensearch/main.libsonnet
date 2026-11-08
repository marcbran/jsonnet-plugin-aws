local a = import 'arcourse-ui/main.libsonnet',
      aws = import 'mixins.libsonnet',
      root = import 'root',
      call(ctx, operation, input) = std.native('invoke:aws')('call', [ctx, 'opensearch', operation, input]);

[
  [['aws', '$account', '$region'], {
    links+: {
      OpenSearch: root.aws.account($.account).region($.region).opensearch,
    },
  }],
  [['aws', '$account', '$region', 'opensearch']],
  [['aws', '$account', '$region', 'opensearch', 'applications'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'nextToken',
    outputToken:: 'nextToken',
    pageSize:: 'maxResults',
    response:: call(
      self.ctx,
      'ListApplications',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['ApplicationSummaries'],
      columns: [
        { key: 'name', kind: 'name', label: 'Name', path: ['name'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['status'], priority: 'secondary' },
        { key: 'id', kind: 'identifier', label: 'ID', path: ['id'], priority: 'secondary' },
        { key: 'lastUpdatedAt', kind: 'timestamp', label: 'Last updated', path: ['lastUpdatedAt'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['ApplicationSummaries'],
        keys: [{ path: ['id'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'opensearch' }, { const: 'applications' }, { param: 'id', path: ['id'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'opensearch', 'applications', '$id'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'GetApplication',
      {
        id: $.id,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', '$region', 'opensearch', 'applications', '$id', 'dataSourceAttachments'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'ListDataSourceAttachments',
      {
        id: $.id,
        maxResults: std.get($._params, 'maxResults', null),
        nextToken: std.get($._params, 'nextToken', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['attachments'],
      columns: [
        { key: 'attachmentId', kind: 'identifier', label: 'Attachment ID', path: ['attachmentId'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['status'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['attachments'],
        keys: [{ path: ['dataSourceArn'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'opensearch' }, { const: 'applications' }, { origin: 'id' }, { const: 'dataSourceAttachments' }, { param: 'dataSourceArn', path: ['dataSourceArn'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'maxResults', type: 'number' },
      { default: null, name: 'nextToken', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'opensearch', 'applications', '$id', 'dataSourceAttachments', '$dataSourceArn'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeDataSourceAttachment',
      {
        dataSourceArn: $.dataSourceArn,
        id: $.id,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'ListDomainNames',
      {
        EngineType: std.get($._params, 'EngineType', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['DomainNames'],
      columns: [
        { key: 'domainName', kind: 'name', label: 'Domain name', path: ['DomainName'], priority: 'primary' },
        { key: 'engineType', kind: 'text', label: 'Engine', path: ['EngineType'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['DomainNames'],
        keys: [{ path: ['DomainName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'opensearch' }, { const: 'domains' }, { param: 'DomainName', path: ['DomainName'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'EngineType', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeDomain',
      {
        DomainName: $.DomainName,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'dataSources'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'ListDataSources',
      {
        DomainName: $.DomainName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['DataSources'],
      columns: [
        { key: 'name', kind: 'name', label: 'Name', path: ['Name'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['DataSources'],
        keys: [{ path: ['Name'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'opensearch' }, { const: 'domains' }, { origin: 'DomainName' }, { const: 'dataSources' }, { param: 'Name', path: ['Name'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'dataSources', '$Name'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'GetDataSource',
      {
        DomainName: $.DomainName,
        Name: $.Name,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'autoTunes'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribeDomainAutoTunes',
      self.page {
        DomainName: $.DomainName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['AutoTunes'],
      columns: [
        { key: 'actionType', kind: 'status', label: 'Tune type', path: ['AutoTuneDetails', 'ScheduledAutoTuneDetails', 'ActionType'], priority: 'primary' },
        { key: 'date', kind: 'timestamp', label: 'Date', path: ['AutoTuneDetails', 'ScheduledAutoTuneDetails', 'Date'], priority: 'secondary' },
        { key: 'severity', kind: 'status', label: 'Severity', path: ['AutoTuneDetails', 'ScheduledAutoTuneDetails', 'Severity'], priority: 'secondary' },
        { key: 'action', kind: 'text', label: 'Action', path: ['AutoTuneDetails', 'ScheduledAutoTuneDetails', 'Action'], priority: 'tertiary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'changeProgress'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeDomainChangeProgress',
      {
        DomainName: $.DomainName,
        ChangeId: std.get($._params, 'ChangeId', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['ChangeProgressStatus', 'ChangeProgressStages'],
      columns: [
        { key: 'name', kind: 'name', label: 'Stage', path: ['Name'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status'], priority: 'secondary' },
        { key: 'lastUpdated', kind: 'timestamp', label: 'Last updated', path: ['LastUpdated'], priority: 'secondary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'ChangeId', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'maintenances'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'ListDomainMaintenances',
      self.page {
        DomainName: $.DomainName,
        Action: std.get($._params, 'Action', null),
        Status: std.get($._params, 'Status', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['DomainMaintenances'],
      columns: [
        { key: 'domainName', kind: 'name', label: 'Domain', path: ['DomainName'], priority: 'primary' },
        { key: 'maintenanceId', kind: 'identifier', label: 'Maintenance ID', path: ['MaintenanceId'], priority: 'secondary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status'], priority: 'secondary' },
        { key: 'action', kind: 'text', label: 'Action', path: ['Action'], priority: 'secondary' },
        { key: 'updatedAt', kind: 'timestamp', label: 'Updated', path: ['UpdatedAt'], priority: 'tertiary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'Action', type: 'string' },
      { default: null, name: 'Status', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'nodes'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeDomainNodes',
      {
        DomainName: $.DomainName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['DomainNodesStatusList'],
      columns: [
        { key: 'nodeId', kind: 'identifier', label: 'Node ID', path: ['NodeId'], priority: 'primary' },
        { key: 'nodeStatus', kind: 'status', label: 'Status', path: ['NodeStatus'], priority: 'secondary' },
        { key: 'nodeType', kind: 'text', label: 'Node Type', path: ['NodeType'], priority: 'secondary' },
        { key: 'instanceType', kind: 'text', label: 'Instance Type', path: ['InstanceType'], priority: 'secondary' },
        { key: 'availabilityZone', kind: 'text', label: 'Availability Zone', path: ['AvailabilityZone'], priority: 'tertiary' },
        { key: 'storageSize', kind: 'text', label: 'Storage Size', path: ['StorageSize'], priority: 'tertiary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'replication'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeDomainReplication',
      {
        DomainName: $.DomainName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['Peers'],
      columns: [
        { key: 'peer_domain_arn', kind: 'identifier', label: 'Peer domain ARN', path: ['PeerDomainArn'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status'], priority: 'secondary' },
        { key: 'peer_role', kind: 'text', label: 'Peer role', path: ['PeerRole'], priority: 'tertiary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'packages'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'ListPackagesForDomain',
      self.page {
        DomainName: $.DomainName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['DomainPackageDetailsList'],
      columns: [
        { key: 'package_name', kind: 'name', label: 'Package', path: ['PackageName'], priority: 'primary' },
        { key: 'package_id', kind: 'identifier', label: 'Package ID', path: ['PackageID'], priority: 'secondary' },
        { key: 'package_version', kind: 'text', label: 'Version', path: ['PackageVersion'], priority: 'secondary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['DomainPackageStatus'], priority: 'secondary' },
        { key: 'package_type', kind: 'text', label: 'Type', path: ['PackageType'], priority: 'tertiary' },
        { key: 'last_updated', kind: 'timestamp', label: 'Last Updated', path: ['LastUpdated'], priority: 'tertiary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'scheduledActions'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'ListScheduledActions',
      self.page {
        DomainName: $.DomainName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['ScheduledActions'],
      columns: [
        { key: 'id', kind: 'identifier', label: 'ID', path: ['Id'], priority: 'primary' },
        { key: 'type', kind: 'text', label: 'Type', path: ['Type'], priority: 'secondary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status'], priority: 'secondary' },
        { key: 'scheduled_time', kind: 'timestamp', label: 'Scheduled time', path: ['ScheduledTime'], priority: 'secondary' },
        { key: 'severity', kind: 'text', label: 'Severity', path: ['Severity'], priority: 'tertiary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'upgradeHistory'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'GetUpgradeHistory',
      self.page {
        DomainName: $.DomainName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['UpgradeHistories'],
      columns: [
        { key: 'upgradeName', kind: 'name', label: 'Upgrade', path: ['UpgradeName'], priority: 'primary' },
        { key: 'upgradeStatus', kind: 'status', label: 'Status', path: ['UpgradeStatus'], priority: 'secondary' },
        { key: 'startTimestamp', kind: 'timestamp', label: 'Started', path: ['StartTimestamp'], priority: 'secondary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'vpcEndpointAccess'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'ListVpcEndpointAccess',
      {
        DomainName: $.DomainName,
        NextToken: std.get($._params, 'NextToken', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['AuthorizedPrincipalList'],
      columns: [
        { key: 'principal', kind: 'identifier', label: 'Principal', path: ['Principal'], priority: 'primary' },
        { key: 'principalType', kind: 'status', label: 'Principal type', path: ['PrincipalType'], priority: 'secondary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'NextToken', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'vpcEndpoints'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'ListVpcEndpointsForDomain',
      {
        DomainName: $.DomainName,
        NextToken: std.get($._params, 'NextToken', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['VpcEndpointSummaryList'],
      columns: [
        { key: 'vpcEndpointId', kind: 'identifier', label: 'VPC endpoint ID', path: ['VpcEndpointId'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status'], priority: 'secondary' },
        { key: 'owner', kind: 'identifier', label: 'Owner', path: ['VpcEndpointOwner'], priority: 'tertiary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'NextToken', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'config'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeDomainConfig',
      {
        DomainName: $.DomainName,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'health'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeDomainHealth',
      {
        DomainName: $.DomainName,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'dryRunProgress'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeDryRunProgress',
      {
        DomainName: $.DomainName,
        DryRunId: std.get($._params, 'DryRunId', null),
        LoadDryRunConfig: std.get($._params, 'LoadDryRunConfig', null),
      }
    ),
    data: self.response,
    _paramSpecs+: [
      { default: null, name: 'DryRunId', type: 'string' },
      { default: null, name: 'LoadDryRunConfig', type: 'boolean' },
    ],
  }],
  [['aws', '$account', '$region', 'opensearch', 'domains', '$DomainName', 'upgradeStatus'], a.resource.node + aws.regional + {
    response:: call(
      self.ctx,
      'GetUpgradeStatus',
      {
        DomainName: $.DomainName,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', '$region', 'opensearch', 'packages'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'DescribePackages',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['PackageDetailsList'],
      columns: [
        { key: 'packageName', kind: 'name', label: 'Package name', path: ['PackageName'], priority: 'primary' },
        { key: 'packageId', kind: 'identifier', label: 'Package ID', path: ['PackageID'], priority: 'secondary' },
        { key: 'packageStatus', kind: 'status', label: 'Status', path: ['PackageStatus'], priority: 'secondary' },
        { key: 'packageType', kind: 'text', label: 'Type', path: ['PackageType'], priority: 'secondary' },
        { key: 'availablePackageVersion', kind: 'text', label: 'Version', path: ['AvailablePackageVersion'], priority: 'secondary' },
        { key: 'lastUpdatedAt', kind: 'timestamp', label: 'Last updated', path: ['LastUpdatedAt'], priority: 'tertiary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'opensearch', 'versions'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'NextToken',
    outputToken:: 'NextToken',
    pageSize:: 'MaxResults',
    response:: call(
      self.ctx,
      'ListVersions',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['Versions'],
      columns: [
        { key: 'version', kind: 'text', label: 'Version', path: [], priority: 'primary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'opensearch', 'vpcEndpoints'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'ListVpcEndpoints',
      {
        NextToken: std.get($._params, 'NextToken', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['VpcEndpointSummaryList'],
      columns: [
        { key: 'vpcEndpointId', kind: 'identifier', label: 'Endpoint ID', path: ['VpcEndpointId'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status'], priority: 'secondary' },
        { key: 'owner', kind: 'identifier', label: 'Owner', path: ['VpcEndpointOwner'], priority: 'tertiary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'NextToken', type: 'string' },
    ],
  }],
]
