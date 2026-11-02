local a = import 'arcourse-ui/main.libsonnet',
      aws = import 'mixins.libsonnet',
      root = import 'root',
      call(ctx, operation, input) = std.native('invoke:aws')('call', [ctx, 'rds', operation, input]);

[
  [['aws', '$account', '$region'], {
    links+: {
      RDS: root.aws.account($.account).region($.region).rds,
    },
  }],
  [['aws', '$account', '$region', 'rds']],
  [['aws', '$account', '$region', 'rds', 'dbClusterParameterGroups'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxRecords',
    response:: call(
      self.ctx,
      'DescribeDBClusterParameterGroups',
      self.page {
        DBClusterParameterGroupName: std.get($._params, 'DBClusterParameterGroupName', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['DBClusterParameterGroups'],
      columns: [
        { key: 'DBClusterParameterGroupName', kind: 'name', label: 'Parameter group', path: ['DBClusterParameterGroupName'], priority: 'primary' },
        { key: 'DBParameterGroupFamily', kind: 'text', label: 'Family', path: ['DBParameterGroupFamily'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['DBClusterParameterGroups'],
        keys: [{ path: ['DBClusterParameterGroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusterParameterGroups' }, { param: 'DBClusterParameterGroupName', path: ['DBClusterParameterGroupName'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'DBClusterParameterGroupName', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbClusterParameterGroups', '$DBClusterParameterGroupName'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['DBClusterParameterGroups'],
    response:: call(
      self.ctx,
      'DescribeDBClusterParameterGroups',
      {
        DBClusterParameterGroupName: $.DBClusterParameterGroupName,
      }
    ),
  }],
  [['aws', '$account', '$region', 'rds', 'dbClusterParameterGroups', '$DBClusterParameterGroupName', 'dbClusterParameters'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxRecords',
    response:: call(
      self.ctx,
      'DescribeDBClusterParameters',
      self.page {
        DBClusterParameterGroupName: $.DBClusterParameterGroupName,
        Source: std.get($._params, 'Source', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['Parameters'],
      columns: [
        { key: 'parameterName', kind: 'name', label: 'Parameter name', path: ['ParameterName'], priority: 'primary' },
        { key: 'parameterValue', kind: 'text', label: 'Value', path: ['ParameterValue'], priority: 'secondary' },
        { key: 'applyMethod', kind: 'status', label: 'Apply method', path: ['ApplyMethod'], priority: 'secondary' },
        { key: 'isModifiable', kind: 'boolean', label: 'Modifiable', path: ['IsModifiable'], priority: 'secondary' },
        { key: 'dataType', kind: 'text', label: 'Data type', path: ['DataType'], priority: 'tertiary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'Source', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbClusterSnapshots'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxRecords',
    response:: call(
      self.ctx,
      'DescribeDBClusterSnapshots',
      self.page {
        DBClusterIdentifier: std.get($._params, 'DBClusterIdentifier', null),
        DBClusterSnapshotIdentifier: std.get($._params, 'DBClusterSnapshotIdentifier', null),
        DbClusterResourceId: std.get($._params, 'DbClusterResourceId', null),
        IncludePublic: std.get($._params, 'IncludePublic', null),
        IncludeShared: std.get($._params, 'IncludeShared', null),
        SnapshotType: std.get($._params, 'SnapshotType', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['DBClusterSnapshots'],
      columns: [
        { key: 'snapshot', kind: 'name', label: 'Snapshot', path: ['DBClusterSnapshotIdentifier'], priority: 'primary' },
        { key: 'cluster', kind: 'name', label: 'Cluster', path: ['DBClusterIdentifier'], priority: 'secondary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status'], priority: 'secondary' },
        { key: 'created', kind: 'timestamp', label: 'Created', path: ['SnapshotCreateTime'], priority: 'secondary' },
        { key: 'engine_version', kind: 'text', label: 'Engine version', path: ['EngineVersion'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['DBClusterSnapshots'],
        keys: [{ path: ['DBClusterSnapshotIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusterSnapshots' }, { param: 'DBClusterSnapshotIdentifier', path: ['DBClusterSnapshotIdentifier'] }],
      },
      {
        at: ['DBClusterSnapshots'],
        keys: [{ const: 'cluster' }, { path: ['DBClusterSnapshotIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusters' }, { param: 'DBClusterIdentifier', path: ['DBClusterIdentifier'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'DBClusterIdentifier', type: 'string' },
      { default: null, name: 'DBClusterSnapshotIdentifier', type: 'string' },
      { default: null, name: 'DbClusterResourceId', type: 'string' },
      { default: null, name: 'IncludePublic', type: 'boolean' },
      { default: null, name: 'IncludeShared', type: 'boolean' },
      { default: null, name: 'SnapshotType', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbClusterSnapshots', '$DBClusterSnapshotIdentifier'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['DBClusterSnapshots'],
    response:: call(
      self.ctx,
      'DescribeDBClusterSnapshots',
      {
        DBClusterSnapshotIdentifier: $.DBClusterSnapshotIdentifier,
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'cluster' }, { path: ['DBClusterSnapshotIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusters' }, { param: 'DBClusterIdentifier', path: ['DBClusterIdentifier'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbClusterSnapshots', '$DBClusterSnapshotIdentifier', 'attributes'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'DescribeDBClusterSnapshotAttributes',
      {
        DBClusterSnapshotIdentifier: $.DBClusterSnapshotIdentifier,
      }
    ),
  }],
  [['aws', '$account', '$region', 'rds', 'dbClusters'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxRecords',
    response:: call(
      self.ctx,
      'DescribeDBClusters',
      self.page {
        DBClusterIdentifier: std.get($._params, 'DBClusterIdentifier', null),
        IncludeShared: std.get($._params, 'IncludeShared', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['DBClusters'],
      columns: [
        { key: 'db_cluster_identifier', kind: 'name', label: 'Cluster', path: ['DBClusterIdentifier'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status'], priority: 'secondary' },
        { key: 'engine', kind: 'text', label: 'Engine', path: ['Engine'], priority: 'secondary' },
        { key: 'engine_version', kind: 'text', label: 'Engine version', path: ['EngineVersion'], priority: 'secondary' },
        { key: 'created', kind: 'timestamp', label: 'Created', path: ['ClusterCreateTime'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['DBClusters'],
        keys: [{ path: ['DBClusterIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusters' }, { param: 'DBClusterIdentifier', path: ['DBClusterIdentifier'] }],
      },
      {
        at: ['DBClusters'],
        keys: [{ const: 'parameter group' }, { path: ['DBClusterIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusterParameterGroups' }, { param: 'DBClusterParameterGroupName', path: ['DBClusterParameterGroup'] }],
      },
      {
        at: ['DBClusters'],
        keys: [{ const: 'subnet group' }, { path: ['DBClusterIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbSubnetGroups' }, { param: 'DBSubnetGroupName', path: ['DBSubnetGroup'] }],
      },
      {
        at: ['DBClusters', 'DBClusterMembers'],
        keys: [{ const: 'DB instance' }, { path: ['DBInstanceIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbInstances' }, { param: 'DBInstanceIdentifier', path: ['DBInstanceIdentifier'] }],
      },
      {
        at: ['DBClusters', 'DBClusterOptionGroupMemberships'],
        keys: [{ const: 'option group' }, { path: ['DBClusterOptionGroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'optionGroups' }, { param: 'OptionGroupName', path: ['DBClusterOptionGroupName'] }],
      },
      {
        at: ['DBClusters', 'ReadReplicaIdentifiers'],
        keys: [{ const: 'read replica' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusters' }, { param: 'DBClusterIdentifier', path: [] }],
      },
      {
        at: ['DBClusters'],
        keys: [{ const: 'source cluster' }, { path: ['DBClusterIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusters' }, { param: 'DBClusterIdentifier', path: ['ReplicationSourceIdentifier'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'DBClusterIdentifier', type: 'string' },
      { default: null, name: 'IncludeShared', type: 'boolean' },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbClusters', '$DBClusterIdentifier'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['DBClusters'],
    response:: call(
      self.ctx,
      'DescribeDBClusters',
      {
        DBClusterIdentifier: $.DBClusterIdentifier,
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'parameter group' }, { path: ['DBClusterIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusterParameterGroups' }, { param: 'DBClusterParameterGroupName', path: ['DBClusterParameterGroup'] }],
      },
      {
        at: [],
        keys: [{ const: 'subnet group' }, { path: ['DBClusterIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbSubnetGroups' }, { param: 'DBSubnetGroupName', path: ['DBSubnetGroup'] }],
      },
      {
        at: ['DBClusterMembers'],
        keys: [{ const: 'DB instance' }, { path: ['DBInstanceIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbInstances' }, { param: 'DBInstanceIdentifier', path: ['DBInstanceIdentifier'] }],
      },
      {
        at: ['DBClusterOptionGroupMemberships'],
        keys: [{ const: 'option group' }, { path: ['DBClusterOptionGroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'optionGroups' }, { param: 'OptionGroupName', path: ['DBClusterOptionGroupName'] }],
      },
      {
        at: ['ReadReplicaIdentifiers'],
        keys: [{ const: 'read replica' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusters' }, { param: 'DBClusterIdentifier', path: [] }],
      },
      {
        at: [],
        keys: [{ const: 'source cluster' }, { path: ['DBClusterIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusters' }, { param: 'DBClusterIdentifier', path: ['ReplicationSourceIdentifier'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbClusters', '$DBClusterIdentifier', 'backtracks'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxRecords',
    response:: call(
      self.ctx,
      'DescribeDBClusterBacktracks',
      self.page {
        DBClusterIdentifier: $.DBClusterIdentifier,
        BacktrackIdentifier: std.get($._params, 'BacktrackIdentifier', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['DBClusterBacktracks'],
      columns: [
        { key: 'backtrackIdentifier', kind: 'identifier', label: 'Backtrack ID', path: ['BacktrackIdentifier'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status'], priority: 'secondary' },
        { key: 'backtrackRequestCreationTime', kind: 'timestamp', label: 'Requested', path: ['BacktrackRequestCreationTime'], priority: 'secondary' },
        { key: 'backtrackTo', kind: 'timestamp', label: 'Backtrack To', path: ['BacktrackTo'], priority: 'secondary' },
        { key: 'dbClusterIdentifier', kind: 'name', label: 'DB Cluster', path: ['DBClusterIdentifier'], priority: 'tertiary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'BacktrackIdentifier', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbInstances'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxRecords',
    response:: call(
      self.ctx,
      'DescribeDBInstances',
      self.page {
        DBInstanceIdentifier: std.get($._params, 'DBInstanceIdentifier', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['DBInstances'],
      columns: [
        { key: 'dbInstanceIdentifier', kind: 'name', label: 'DB instance', path: ['DBInstanceIdentifier'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['DBInstanceStatus'], priority: 'secondary' },
        { key: 'engine', kind: 'text', label: 'Engine', path: ['Engine'], priority: 'secondary' },
        { key: 'instanceClass', kind: 'text', label: 'Class', path: ['DBInstanceClass'], priority: 'secondary' },
        { key: 'availabilityZone', kind: 'text', label: 'Availability zone', path: ['AvailabilityZone'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['DBInstances'],
        keys: [{ path: ['DBInstanceIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbInstances' }, { param: 'DBInstanceIdentifier', path: ['DBInstanceIdentifier'] }],
      },
      {
        at: ['DBInstances', 'DBParameterGroups'],
        keys: [{ const: 'parameter group' }, { path: ['DBParameterGroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbParameterGroups' }, { param: 'DBParameterGroupName', path: ['DBParameterGroupName'] }],
      },
      {
        at: ['DBInstances'],
        keys: [{ const: 'subnet group' }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbSubnetGroups' }, { param: 'DBSubnetGroupName', path: ['DBSubnetGroup', 'DBSubnetGroupName'] }],
      },
      {
        at: ['DBInstances', 'OptionGroupMemberships'],
        keys: [{ const: 'option group' }, { path: ['OptionGroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'optionGroups' }, { param: 'OptionGroupName', path: ['OptionGroupName'] }],
      },
      {
        at: ['DBInstances'],
        keys: [{ const: 'read replica source cluster' }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusters' }, { param: 'DBClusterIdentifier', path: ['ReadReplicaSourceDBClusterIdentifier'] }],
      },
      {
        at: ['DBInstances'],
        keys: [{ const: 'read replica source instance' }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbInstances' }, { param: 'DBInstanceIdentifier', path: ['ReadReplicaSourceDBInstanceIdentifier'] }],
      },
      {
        at: ['DBInstances', 'ReadReplicaDBClusterIdentifiers'],
        keys: [{ const: 'read replica cluster' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusters' }, { param: 'DBClusterIdentifier', path: [] }],
      },
      {
        at: ['DBInstances', 'ReadReplicaDBInstanceIdentifiers'],
        keys: [{ const: 'read replica instance' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbInstances' }, { param: 'DBInstanceIdentifier', path: [] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'DBInstanceIdentifier', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbInstances', '$DBInstanceIdentifier'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['DBInstances'],
    response:: call(
      self.ctx,
      'DescribeDBInstances',
      {
        DBInstanceIdentifier: $.DBInstanceIdentifier,
      }
    ),
    linkSpecs:: [
      {
        at: ['DBParameterGroups'],
        keys: [{ const: 'parameter group' }, { path: ['DBParameterGroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbParameterGroups' }, { param: 'DBParameterGroupName', path: ['DBParameterGroupName'] }],
      },
      {
        at: [],
        keys: [{ const: 'subnet group' }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbSubnetGroups' }, { param: 'DBSubnetGroupName', path: ['DBSubnetGroup', 'DBSubnetGroupName'] }],
      },
      {
        at: ['OptionGroupMemberships'],
        keys: [{ const: 'option group' }, { path: ['OptionGroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'optionGroups' }, { param: 'OptionGroupName', path: ['OptionGroupName'] }],
      },
      {
        at: [],
        keys: [{ const: 'read replica source cluster' }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusters' }, { param: 'DBClusterIdentifier', path: ['ReadReplicaSourceDBClusterIdentifier'] }],
      },
      {
        at: [],
        keys: [{ const: 'read replica source instance' }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbInstances' }, { param: 'DBInstanceIdentifier', path: ['ReadReplicaSourceDBInstanceIdentifier'] }],
      },
      {
        at: ['ReadReplicaDBClusterIdentifiers'],
        keys: [{ const: 'read replica cluster' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbClusters' }, { param: 'DBClusterIdentifier', path: [] }],
      },
      {
        at: ['ReadReplicaDBInstanceIdentifiers'],
        keys: [{ const: 'read replica instance' }, { path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbInstances' }, { param: 'DBInstanceIdentifier', path: [] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbInstances', '$DBInstanceIdentifier', 'dbLogFiles'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxRecords',
    response:: call(
      self.ctx,
      'DescribeDBLogFiles',
      self.page {
        DBInstanceIdentifier: $.DBInstanceIdentifier,
        FileLastWritten: std.get($._params, 'FileLastWritten', null),
        FileSize: std.get($._params, 'FileSize', null),
        FilenameContains: std.get($._params, 'FilenameContains', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['DescribeDBLogFiles'],
      columns: [
        { key: 'LogFileName', kind: 'name', label: 'Log file', path: ['LogFileName'], priority: 'primary' },
        { key: 'LastWritten', kind: 'timestamp', label: 'Last written', path: ['LastWritten'], priority: 'secondary' },
        { key: 'Size', kind: 'number', label: 'Size', path: ['Size'], priority: 'secondary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'FileLastWritten', type: 'number' },
      { default: null, name: 'FileSize', type: 'number' },
      { default: null, name: 'FilenameContains', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbInstances', '$DBInstanceIdentifier', 'validModifications'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'DescribeValidDBInstanceModifications',
      {
        DBInstanceIdentifier: $.DBInstanceIdentifier,
      }
    ),
  }],
  [['aws', '$account', '$region', 'rds', 'dbParameterGroups'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxRecords',
    response:: call(
      self.ctx,
      'DescribeDBParameterGroups',
      self.page {
        DBParameterGroupName: std.get($._params, 'DBParameterGroupName', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['DBParameterGroups'],
      columns: [
        { key: 'name', kind: 'name', label: 'Parameter group', path: ['DBParameterGroupName'], priority: 'primary' },
        { key: 'family', kind: 'text', label: 'Family', path: ['DBParameterGroupFamily'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['DBParameterGroups'],
        keys: [{ path: ['DBParameterGroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbParameterGroups' }, { param: 'DBParameterGroupName', path: ['DBParameterGroupName'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'DBParameterGroupName', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbParameterGroups', '$DBParameterGroupName'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['DBParameterGroups'],
    response:: call(
      self.ctx,
      'DescribeDBParameterGroups',
      {
        DBParameterGroupName: $.DBParameterGroupName,
      }
    ),
  }],
  [['aws', '$account', '$region', 'rds', 'dbParameterGroups', '$DBParameterGroupName', 'dbParameters'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxRecords',
    response:: call(
      self.ctx,
      'DescribeDBParameters',
      self.page {
        DBParameterGroupName: $.DBParameterGroupName,
        Source: std.get($._params, 'Source', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['Parameters'],
      columns: [
        { key: 'parameter_name', kind: 'name', label: 'Parameter', path: ['ParameterName'], priority: 'primary' },
        { key: 'parameter_value', kind: 'text', label: 'Value', path: ['ParameterValue'], priority: 'secondary' },
        { key: 'apply_method', kind: 'status', label: 'Apply method', path: ['ApplyMethod'], priority: 'secondary' },
        { key: 'is_modifiable', kind: 'boolean', label: 'Modifiable', path: ['IsModifiable'], priority: 'secondary' },
        { key: 'data_type', kind: 'text', label: 'Data type', path: ['DataType'], priority: 'tertiary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'Source', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbSnapshots'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxRecords',
    response:: call(
      self.ctx,
      'DescribeDBSnapshots',
      self.page {
        DBInstanceIdentifier: std.get($._params, 'DBInstanceIdentifier', null),
        DBSnapshotIdentifier: std.get($._params, 'DBSnapshotIdentifier', null),
        DbiResourceId: std.get($._params, 'DbiResourceId', null),
        IncludePublic: std.get($._params, 'IncludePublic', null),
        IncludeShared: std.get($._params, 'IncludeShared', null),
        SnapshotType: std.get($._params, 'SnapshotType', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['DBSnapshots'],
      columns: [
        { key: 'snapshotId', kind: 'name', label: 'Snapshot ID', path: ['DBSnapshotIdentifier'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status'], priority: 'secondary' },
        { key: 'dbInstance', kind: 'name', label: 'DB Instance', path: ['DBInstanceIdentifier'], priority: 'secondary' },
        { key: 'engine', kind: 'text', label: 'Engine', path: ['Engine'], priority: 'secondary' },
        { key: 'created', kind: 'timestamp', label: 'Created', path: ['SnapshotCreateTime'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['DBSnapshots'],
        keys: [{ path: ['DBSnapshotIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbSnapshots' }, { param: 'DBSnapshotIdentifier', path: ['DBSnapshotIdentifier'] }],
      },
      {
        at: ['DBSnapshots'],
        keys: [{ const: 'DB instance' }, { path: ['DBSnapshotIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbInstances' }, { param: 'DBInstanceIdentifier', path: ['DBInstanceIdentifier'] }],
      },
      {
        at: ['DBSnapshots'],
        keys: [{ const: 'option group' }, { path: ['DBSnapshotIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'optionGroups' }, { param: 'OptionGroupName', path: ['OptionGroupName'] }],
      },
      {
        at: ['DBSnapshots'],
        keys: [{ const: 'source snapshot' }, { path: ['DBSnapshotIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbSnapshots' }, { param: 'DBSnapshotIdentifier', path: ['SourceDBSnapshotIdentifier'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'DBInstanceIdentifier', type: 'string' },
      { default: null, name: 'DBSnapshotIdentifier', type: 'string' },
      { default: null, name: 'DbiResourceId', type: 'string' },
      { default: null, name: 'IncludePublic', type: 'boolean' },
      { default: null, name: 'IncludeShared', type: 'boolean' },
      { default: null, name: 'SnapshotType', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbSnapshots', '$DBSnapshotIdentifier'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['DBSnapshots'],
    response:: call(
      self.ctx,
      'DescribeDBSnapshots',
      {
        DBSnapshotIdentifier: $.DBSnapshotIdentifier,
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'DB instance' }, { path: ['DBSnapshotIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbInstances' }, { param: 'DBInstanceIdentifier', path: ['DBInstanceIdentifier'] }],
      },
      {
        at: [],
        keys: [{ const: 'option group' }, { path: ['DBSnapshotIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'optionGroups' }, { param: 'OptionGroupName', path: ['OptionGroupName'] }],
      },
      {
        at: [],
        keys: [{ const: 'source snapshot' }, { path: ['DBSnapshotIdentifier'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbSnapshots' }, { param: 'DBSnapshotIdentifier', path: ['SourceDBSnapshotIdentifier'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbSnapshots', '$DBSnapshotIdentifier', 'attributes'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'DescribeDBSnapshotAttributes',
      {
        DBSnapshotIdentifier: $.DBSnapshotIdentifier,
      }
    ),
  }],
  [['aws', '$account', '$region', 'rds', 'dbSubnetGroups'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxRecords',
    response:: call(
      self.ctx,
      'DescribeDBSubnetGroups',
      self.page {
        DBSubnetGroupName: std.get($._params, 'DBSubnetGroupName', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['DBSubnetGroups'],
      columns: [
        { key: 'dbSubnetGroupName', kind: 'name', label: 'Subnet Group', path: ['DBSubnetGroupName'], priority: 'primary' },
        { key: 'subnetGroupStatus', kind: 'status', label: 'Status', path: ['SubnetGroupStatus'], priority: 'secondary' },
        { key: 'vpcId', kind: 'identifier', label: 'VPC ID', path: ['VpcId'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['DBSubnetGroups'],
        keys: [{ path: ['DBSubnetGroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'dbSubnetGroups' }, { param: 'DBSubnetGroupName', path: ['DBSubnetGroupName'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'DBSubnetGroupName', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'dbSubnetGroups', '$DBSubnetGroupName'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['DBSubnetGroups'],
    response:: call(
      self.ctx,
      'DescribeDBSubnetGroups',
      {
        DBSubnetGroupName: $.DBSubnetGroupName,
      }
    ),
  }],
  [['aws', '$account', '$region', 'rds', 'optionGroups'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxRecords',
    response:: call(
      self.ctx,
      'DescribeOptionGroups',
      self.page {
        EngineName: std.get($._params, 'EngineName', null),
        MajorEngineVersion: std.get($._params, 'MajorEngineVersion', null),
        OptionGroupName: std.get($._params, 'OptionGroupName', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['OptionGroupsList'],
      columns: [
        { key: 'optionGroupName', kind: 'name', label: 'Option Group', path: ['OptionGroupName'], priority: 'primary' },
        { key: 'engineName', kind: 'text', label: 'Engine', path: ['EngineName'], priority: 'secondary' },
        { key: 'majorEngineVersion', kind: 'text', label: 'Engine Version', path: ['MajorEngineVersion'], priority: 'secondary' },
        { key: 'vpcId', kind: 'identifier', label: 'VPC', path: ['VpcId'], priority: 'secondary' },
        { key: 'copyTimestamp', kind: 'timestamp', label: 'Copied', path: ['CopyTimestamp'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['OptionGroupsList'],
        keys: [{ path: ['OptionGroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'optionGroups' }, { param: 'OptionGroupName', path: ['OptionGroupName'] }],
      },
      {
        at: ['OptionGroupsList'],
        keys: [{ const: 'source option group' }, { path: ['OptionGroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'optionGroups' }, { param: 'OptionGroupName', path: ['SourceOptionGroup'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'EngineName', type: 'string' },
      { default: null, name: 'MajorEngineVersion', type: 'string' },
      { default: null, name: 'OptionGroupName', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 'rds', 'optionGroups', '$OptionGroupName'], a.resource.node + aws.regional + aws.single + {
    itemsPath:: ['OptionGroupsList'],
    response:: call(
      self.ctx,
      'DescribeOptionGroups',
      {
        OptionGroupName: $.OptionGroupName,
      }
    ),
    linkSpecs:: [
      {
        at: [],
        keys: [{ const: 'source option group' }, { path: ['OptionGroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 'rds' }, { const: 'optionGroups' }, { param: 'OptionGroupName', path: ['SourceOptionGroup'] }],
      },
    ],
  }],
]
