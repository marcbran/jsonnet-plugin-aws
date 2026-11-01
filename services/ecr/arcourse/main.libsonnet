local a = import 'arcourse-ui/main.libsonnet',
      aws = import 'mixins.libsonnet',
      root = import 'root',
      call(ctx, operation, input) = std.native('invoke:aws')('call', [ctx, 'ecr', operation, input]);

[
  [['aws', '$account', '$region'], {
    links+: {
      ECR: root.aws.account($.account).region($.region).ecr,
    },
  }],
  [['aws', '$account', '$region', 'ecr']],
  [['aws', '$account', '$region', 'ecr', 'pullThroughCacheRules'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'nextToken',
    outputToken:: 'nextToken',
    pageSize:: 'maxResults',
    response:: call(
      self.ctx,
      'DescribePullThroughCacheRules',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['pullThroughCacheRules'],
      columns: [
        { key: 'ecrRepositoryPrefix', kind: 'name', label: 'Repository prefix', path: ['ecrRepositoryPrefix'], priority: 'primary' },
        { key: 'upstreamRegistry', kind: 'text', label: 'Upstream registry', path: ['upstreamRegistry'], priority: 'secondary' },
        { key: 'upstreamRepositoryPrefix', kind: 'text', label: 'Upstream prefix', path: ['upstreamRepositoryPrefix'], priority: 'secondary' },
        { key: 'updatedAt', kind: 'timestamp', label: 'Updated', path: ['updatedAt'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['pullThroughCacheRules'],
        keys: [{ path: ['ecrRepositoryPrefix'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ecr' }, { const: 'pullThroughCacheRules' }, { param: 'ecrRepositoryPrefix', path: ['ecrRepositoryPrefix'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ecr', 'pullThroughCacheRules', '$ecrRepositoryPrefix'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['pullThroughCacheRules'],
    response:: call(
      self.ctx,
      'DescribePullThroughCacheRules',
      {
        ecrRepositoryPrefixes: [$.ecrRepositoryPrefix],
      }
    ),
  }],
  [['aws', '$account', '$region', 'ecr', 'pullTimeUpdateExclusions'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'ListPullTimeUpdateExclusions',
      {
        maxResults: std.get($._params, 'maxResults', null),
        nextToken: std.get($._params, 'nextToken', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['pullTimeUpdateExclusions'],
      columns: [
        { key: 'exclusion', kind: 'text', label: 'Exclusion', path: [], priority: 'primary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'maxResults', type: 'number' },
      { default: null, name: 'nextToken', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'ecr', 'replicationBackfills'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'nextToken',
    outputToken:: 'nextToken',
    pageSize:: 'maxResults',
    response:: call(
      self.ctx,
      'ListReplicationBackfills',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['backfills'],
      columns: [
        { key: 'replicationBackfillId', kind: 'identifier', label: 'Backfill ID', path: ['replicationBackfillId'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['status'], priority: 'secondary' },
        { key: 'destinationRegion', kind: 'text', label: 'Region', path: ['destination', 'region'], priority: 'secondary' },
        { key: 'startedAt', kind: 'timestamp', label: 'Started', path: ['startedAt'], priority: 'secondary' },
        { key: 'endedAt', kind: 'timestamp', label: 'Ended', path: ['endedAt'], priority: 'tertiary' },
        { key: 'totalReplicationCount', kind: 'count', label: 'Total Replications', path: ['progress', 'totalReplicationCount'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['backfills'],
        keys: [{ path: ['replicationBackfillId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ecr' }, { const: 'replicationBackfills' }, { param: 'replicationBackfillId', path: ['replicationBackfillId'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ecr', 'replicationBackfills', '$replicationBackfillId']],
  [['aws', '$account', '$region', 'ecr', 'replicationBackfills', '$replicationBackfillId', 'results'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'nextToken',
    outputToken:: 'nextToken',
    pageSize:: 'maxResults',
    response:: call(
      self.ctx,
      'DescribeReplicationBackfillResults',
      self.page {
        replicationBackfillId: $.replicationBackfillId,
        resultStatusFilter: std.get($._params, 'resultStatusFilter', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['results'],
      columns: [
        { key: 'repositoryName', kind: 'name', label: 'Repository', path: ['repositoryName'], priority: 'primary' },
        { key: 'imageTag', kind: 'name', label: 'Image tag', path: ['imageId', 'imageTag'], priority: 'secondary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['status'], priority: 'secondary' },
        { key: 'failureCode', kind: 'text', label: 'Failure code', path: ['failureCode'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['results'],
        keys: [{ const: 'repository' }, { path: ['repositoryName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ecr' }, { const: 'repositories' }, { param: 'repositoryName', path: ['repositoryName'] }],
      },
      {
        at: ['results'],
        keys: [{ const: 'image' }, { path: ['repositoryName'] }, { path: ['imageId', 'imageDigest'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ecr' }, { const: 'repositories' }, { param: 'repositoryName', path: ['repositoryName'] }, { const: 'images' }, { param: 'imageDigest', path: ['imageId', 'imageDigest'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'resultStatusFilter', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'ecr', 'repositories'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'nextToken',
    outputToken:: 'nextToken',
    pageSize:: 'maxResults',
    response:: call(
      self.ctx,
      'DescribeRepositories',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['repositories'],
      columns: [
        { key: 'repositoryName', kind: 'name', label: 'Repository', path: ['repositoryName'], priority: 'primary' },
        { key: 'createdAt', kind: 'timestamp', label: 'Created', path: ['createdAt'], priority: 'secondary' },
        { key: 'scanOnPush', kind: 'boolean', label: 'Scan on push', path: ['imageScanningConfiguration', 'scanOnPush'], priority: 'secondary' },
        { key: 'imageTagMutability', kind: 'status', label: 'Tag mutability', path: ['imageTagMutability'], priority: 'secondary' },
        { key: 'encryptionType', kind: 'status', label: 'Encryption', path: ['encryptionConfiguration', 'encryptionType'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['repositories'],
        keys: [{ path: ['repositoryName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ecr' }, { const: 'repositories' }, { param: 'repositoryName', path: ['repositoryName'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ecr', 'repositories', '$repositoryName'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['repositories'],
    response:: call(
      self.ctx,
      'DescribeRepositories',
      {
        repositoryNames: [$.repositoryName],
      }
    ),
  }],
  [['aws', '$account', '$region', 'ecr', 'repositories', '$repositoryName', 'images'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'nextToken',
    outputToken:: 'nextToken',
    pageSize:: 'maxResults',
    response:: call(
      self.ctx,
      'DescribeImages',
      self.page {
        repositoryName: $.repositoryName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['imageDetails'],
      columns: [
        { key: 'imageDigest', kind: 'identifier', label: 'Image digest', path: ['imageDigest'], priority: 'primary' },
        { key: 'imagePushedAt', kind: 'timestamp', label: 'Pushed', path: ['imagePushedAt'], priority: 'secondary' },
        { key: 'imageStatus', kind: 'status', label: 'Image status', path: ['imageStatus'], priority: 'secondary' },
        { key: 'scanStatus', kind: 'status', label: 'Scan status', path: ['imageScanStatus', 'status'], priority: 'secondary' },
        { key: 'imageSizeInBytes', kind: 'number', label: 'Size', path: ['imageSizeInBytes'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['imageDetails'],
        keys: [{ path: ['imageDigest'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ecr' }, { const: 'repositories' }, { origin: 'repositoryName' }, { const: 'images' }, { param: 'imageDigest', path: ['imageDigest'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ecr', 'repositories', '$repositoryName', 'images', '$imageDigest'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['imageDetails'],
    response:: call(
      self.ctx,
      'DescribeImages',
      {
        repositoryName: $.repositoryName,
        imageIds: [{
          imageDigest: $.imageDigest,
        }],
      }
    ),
  }],
  [['aws', '$account', '$region', 'ecr', 'repositories', '$repositoryName', 'images', '$imageDigest', 'replicationStatus'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeImageReplicationStatus',
      {
        imageId: {
          imageDigest: $.imageDigest,
        },
        repositoryName: $.repositoryName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['replicationStatuses'],
      columns: [
        { key: 'region', kind: 'name', label: 'Region', path: ['region'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['status'], priority: 'secondary' },
        { key: 'failureCode', kind: 'text', label: 'Failure code', path: ['failureCode'], priority: 'tertiary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'ecr', 'repositories', '$repositoryName', 'images', '$imageDigest', 'scanFindings'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'nextToken',
    outputToken:: 'nextToken',
    pageSize:: 'maxResults',
    response:: call(
      self.ctx,
      'DescribeImageScanFindings',
      self.page {
        imageId: {
          imageDigest: $.imageDigest,
        },
        repositoryName: $.repositoryName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['imageScanFindings', 'findings'],
      columns: [
        { label: 'Name', path: ['name'] },
        { label: 'Description', path: ['description'] },
        { label: 'Severity', path: ['severity'] },
        { label: 'Uri', path: ['uri'] },
      ],
    },
  }],
  [['aws', '$account', '$region', 'ecr', 'repositories', '$repositoryName', 'images', '$imageDigest', 'signingStatus'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'DescribeImageSigningStatus',
      {
        imageId: {
          imageDigest: $.imageDigest,
        },
        repositoryName: $.repositoryName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['signingStatuses'],
      columns: [
        { key: 'status', kind: 'status', label: 'Status', path: ['status'], priority: 'primary' },
        { key: 'failureCode', kind: 'text', label: 'Failure code', path: ['failureCode'], priority: 'secondary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'ecr', 'repositories', '$repositoryName', 'lifecyclePolicyPreview'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'nextToken',
    outputToken:: 'nextToken',
    pageSize:: 'maxResults',
    response:: call(
      self.ctx,
      'GetLifecyclePolicyPreview',
      self.page {
        repositoryName: $.repositoryName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['previewResults'],
      columns: [
        { key: 'imageDigest', kind: 'identifier', label: 'Image digest', path: ['imageDigest'], priority: 'primary' },
        { key: 'imagePushedAt', kind: 'timestamp', label: 'Pushed at', path: ['imagePushedAt'], priority: 'secondary' },
        { key: 'actionType', kind: 'status', label: 'Action', path: ['action', 'type'], priority: 'secondary' },
        { key: 'storageClass', kind: 'text', label: 'Storage class', path: ['storageClass'], priority: 'secondary' },
        { key: 'appliedRulePriority', kind: 'number', label: 'Rule priority', path: ['appliedRulePriority'], priority: 'tertiary' },
        { key: 'targetStorageClass', kind: 'text', label: 'Target class', path: ['action', 'targetStorageClass'], priority: 'tertiary' },
      ],
    },
  }],
  [['aws', '$account', '$region', 'ecr', 'repositories', '$repositoryName', 'lifecyclePolicy'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetLifecyclePolicy',
      {
        repositoryName: $.repositoryName,
      }
    ),
  }],
  [['aws', '$account', '$region', 'ecr', 'repositories', '$repositoryName', 'policy'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetRepositoryPolicy',
      {
        repositoryName: $.repositoryName,
      }
    ),
  }],
  [['aws', '$account', '$region', 'ecr', 'repositoryCreationTemplates'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'nextToken',
    outputToken:: 'nextToken',
    pageSize:: 'maxResults',
    response:: call(
      self.ctx,
      'DescribeRepositoryCreationTemplates',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['repositoryCreationTemplates'],
      columns: [
        { key: 'prefix', kind: 'name', label: 'Prefix', path: ['prefix'], priority: 'primary' },
        { key: 'imageTagMutability', kind: 'status', label: 'Tag Mutability', path: ['imageTagMutability'], priority: 'secondary' },
        { key: 'encryptionType', kind: 'text', label: 'Encryption', path: ['encryptionConfiguration', 'encryptionType'], priority: 'secondary' },
        { key: 'updatedAt', kind: 'timestamp', label: 'Updated', path: ['updatedAt'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['repositoryCreationTemplates'],
        keys: [{ path: ['prefix'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'ecr' }, { const: 'repositoryCreationTemplates' }, { param: 'prefix', path: ['prefix'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'ecr', 'repositoryCreationTemplates', '$prefix'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['repositoryCreationTemplates'],
    response:: call(
      self.ctx,
      'DescribeRepositoryCreationTemplates',
      {
        prefixes: [$.prefix],
      }
    ),
  }],
  [['aws', '$account', '$region', 'ecr', 'registryPolicy'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetRegistryPolicy',
      {}
    ),
  }],
  [['aws', '$account', '$region', 'ecr', 'registryScanningConfiguration'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetRegistryScanningConfiguration',
      {}
    ),
  }],
  [['aws', '$account', '$region', 'ecr', 'registry'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'DescribeRegistry',
      {}
    ),
  }],
  [['aws', '$account', '$region', 'ecr', 'signingConfiguration'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetSigningConfiguration',
      {}
    ),
  }],
]
