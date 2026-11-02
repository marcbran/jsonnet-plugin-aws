local a = import 'arcourse-ui/main.libsonnet',
      aws = import 'mixins.libsonnet',
      root = import 'root',
      call(ctx, operation, input) = std.native('invoke:aws')('call', [ctx, 's3', operation, input]);

[
  [['aws', '$account', '$region'], {
    links+: {
      S3: root.aws.account($.account).region($.region).s3,
    },
  }],
  [['aws', '$account', '$region', 's3']],
  [['aws', '$account', '$region', 's3', 'buckets'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'ContinuationToken',
    outputToken:: 'ContinuationToken',
    pageSize:: 'MaxBuckets',
    response:: call(
      self.ctx,
      'ListBuckets',
      self.page {
        BucketRegion: $.region,
        Prefix: std.get($._params, 'Prefix', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['Buckets'],
      columns: [
        { key: 'name', kind: 'name', label: 'Bucket name', path: ['Name'], priority: 'primary' },
        { key: 'region', kind: 'text', label: 'Region', path: ['BucketRegion'], priority: 'secondary' },
        { key: 'created', kind: 'timestamp', label: 'Created', path: ['CreationDate'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['Buckets'],
        keys: [{ path: ['Name'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 's3' }, { const: 'buckets' }, { param: 'Bucket', path: ['Name'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'Prefix', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'HeadBucket',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'analyticsConfigurations'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'ListBucketAnalyticsConfigurations',
      {
        Bucket: $.Bucket,
        ContinuationToken: std.get($._params, 'ContinuationToken', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['AnalyticsConfigurationList'],
      columns: [
        { key: 'id', kind: 'identifier', label: 'ID', path: ['Id'], priority: 'primary' },
        { key: 'filter_prefix', kind: 'text', label: 'Prefix', path: ['Filter', 'Prefix'], priority: 'secondary' },
        { key: 'filter_tag_key', kind: 'text', label: 'Tag key', path: ['Filter', 'Tag', 'Key'], priority: 'secondary' },
        { key: 'filter_tag_value', kind: 'text', label: 'Tag value', path: ['Filter', 'Tag', 'Value'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['AnalyticsConfigurationList'],
        keys: [{ path: ['Id'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 's3' }, { const: 'buckets' }, { origin: 'Bucket' }, { const: 'analyticsConfigurations' }, { param: 'Id', path: ['Id'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'ContinuationToken', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'analyticsConfigurations', '$Id'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketAnalyticsConfiguration',
      {
        Bucket: $.Bucket,
        Id: $.Id,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'intelligentTieringConfigurations'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'ListBucketIntelligentTieringConfigurations',
      {
        Bucket: $.Bucket,
        ContinuationToken: std.get($._params, 'ContinuationToken', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['IntelligentTieringConfigurationList'],
      columns: [
        { key: 'id', kind: 'identifier', label: 'ID', path: ['Id'], priority: 'primary' },
        { key: 'status', kind: 'status', label: 'Status', path: ['Status'], priority: 'secondary' },
        { key: 'prefix', kind: 'text', label: 'Prefix', path: ['Filter', 'Prefix'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['IntelligentTieringConfigurationList'],
        keys: [{ path: ['Id'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 's3' }, { const: 'buckets' }, { origin: 'Bucket' }, { const: 'intelligentTieringConfigurations' }, { param: 'Id', path: ['Id'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'ContinuationToken', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'intelligentTieringConfigurations', '$Id'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketIntelligentTieringConfiguration',
      {
        Bucket: $.Bucket,
        Id: $.Id,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'inventoryConfigurations'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'ListBucketInventoryConfigurations',
      {
        Bucket: $.Bucket,
        ContinuationToken: std.get($._params, 'ContinuationToken', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['InventoryConfigurationList'],
      columns: [
        { key: 'id', kind: 'identifier', label: 'Config ID', path: ['Id'], priority: 'primary' },
        { key: 'enabled', kind: 'boolean', label: 'Enabled', path: ['IsEnabled'], priority: 'secondary' },
        { key: 'destination_bucket', kind: 'name', label: 'Destination bucket', path: ['Destination', 'S3BucketDestination', 'Bucket'], priority: 'secondary' },
        { key: 'frequency', kind: 'text', label: 'Frequency', path: ['Schedule', 'Frequency'], priority: 'secondary' },
        { key: 'included_versions', kind: 'text', label: 'Object versions', path: ['IncludedObjectVersions'], priority: 'secondary' },
        { key: 'format', kind: 'text', label: 'Format', path: ['Destination', 'S3BucketDestination', 'Format'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['InventoryConfigurationList'],
        keys: [{ path: ['Id'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 's3' }, { const: 'buckets' }, { origin: 'Bucket' }, { const: 'inventoryConfigurations' }, { param: 'Id', path: ['Id'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'ContinuationToken', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'inventoryConfigurations', '$Id'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketInventoryConfiguration',
      {
        Bucket: $.Bucket,
        Id: $.Id,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'metricsConfigurations'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'ListBucketMetricsConfigurations',
      {
        Bucket: $.Bucket,
        ContinuationToken: std.get($._params, 'ContinuationToken', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['MetricsConfigurationList'],
      columns: [
        { key: 'id', kind: 'identifier', label: 'ID', path: ['Id'], priority: 'primary' },
        { key: 'prefix', kind: 'text', label: 'Prefix', path: ['Filter', 'Prefix'], priority: 'secondary' },
        { key: 'tag_key', kind: 'text', label: 'Tag key', path: ['Filter', 'Tag', 'Key'], priority: 'secondary' },
        { key: 'tag_value', kind: 'text', label: 'Tag value', path: ['Filter', 'Tag', 'Value'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['MetricsConfigurationList'],
        keys: [{ path: ['Id'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 's3' }, { const: 'buckets' }, { origin: 'Bucket' }, { const: 'metricsConfigurations' }, { param: 'Id', path: ['Id'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'ContinuationToken', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'metricsConfigurations', '$Id'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketMetricsConfiguration',
      {
        Bucket: $.Bucket,
        Id: $.Id,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'multipartUploads'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'ListMultipartUploads',
      {
        Bucket: $.Bucket,
        Delimiter: std.get($._params, 'Delimiter', null),
        EncodingType: std.get($._params, 'EncodingType', null),
        KeyMarker: std.get($._params, 'KeyMarker', null),
        MaxUploads: std.get($._params, 'MaxUploads', null),
        Prefix: std.get($._params, 'Prefix', null),
        UploadIdMarker: std.get($._params, 'UploadIdMarker', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['Uploads'],
      columns: [
        { key: 'key', kind: 'name', label: 'Key', path: ['Key'], priority: 'primary' },
        { key: 'uploadId', kind: 'identifier', label: 'Upload ID', path: ['UploadId'], priority: 'secondary' },
        { key: 'initiated', kind: 'timestamp', label: 'Initiated', path: ['Initiated'], priority: 'secondary' },
        { key: 'storageClass', kind: 'text', label: 'Storage class', path: ['StorageClass'], priority: 'tertiary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'Delimiter', type: 'string' },
      { default: null, name: 'EncodingType', type: 'string' },
      { default: null, name: 'KeyMarker', type: 'string' },
      { default: null, name: 'MaxUploads', type: 'number' },
      { default: null, name: 'Prefix', type: 'string' },
      { default: null, name: 'UploadIdMarker', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'objectVersions'], a.table.node + aws.regional + {
    response:: call(
      self.ctx,
      'ListObjectVersions',
      {
        Bucket: $.Bucket,
        Delimiter: std.get($._params, 'Delimiter', null),
        EncodingType: std.get($._params, 'EncodingType', null),
        KeyMarker: std.get($._params, 'KeyMarker', null),
        MaxKeys: std.get($._params, 'MaxKeys', null),
        Prefix: std.get($._params, 'Prefix', null),
        VersionIdMarker: std.get($._params, 'VersionIdMarker', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['Versions'],
      columns: [
        { key: 'key', kind: 'name', label: 'Key', path: ['Key'], priority: 'primary' },
        { key: 'versionId', kind: 'identifier', label: 'Version ID', path: ['VersionId'], priority: 'secondary' },
        { key: 'isLatest', kind: 'status', label: 'Latest', path: ['IsLatest'], priority: 'secondary' },
        { key: 'lastModified', kind: 'timestamp', label: 'Last modified', path: ['LastModified'], priority: 'secondary' },
        { key: 'size', kind: 'number', label: 'Size', path: ['Size'], priority: 'tertiary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'Delimiter', type: 'string' },
      { default: null, name: 'EncodingType', type: 'string' },
      { default: null, name: 'KeyMarker', type: 'string' },
      { default: null, name: 'MaxKeys', type: 'number' },
      { default: null, name: 'Prefix', type: 'string' },
      { default: null, name: 'VersionIdMarker', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'objects'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'ContinuationToken',
    outputToken:: 'NextContinuationToken',
    pageSize:: 'MaxKeys',
    response:: call(
      self.ctx,
      'ListObjectsV2',
      self.page {
        Bucket: $.Bucket,
        Delimiter: std.get($._params, 'Delimiter', null),
        EncodingType: std.get($._params, 'EncodingType', null),
        FetchOwner: std.get($._params, 'FetchOwner', null),
        Prefix: std.get($._params, 'Prefix', null),
        StartAfter: std.get($._params, 'StartAfter', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['Contents'],
      columns: [
        { key: 'key', kind: 'name', label: 'Key', path: ['Key'], priority: 'primary' },
        { key: 'last_modified', kind: 'timestamp', label: 'Last modified', path: ['LastModified'], priority: 'secondary' },
        { key: 'size', kind: 'number', label: 'Size', path: ['Size'], priority: 'secondary' },
        { key: 'storage_class', kind: 'text', label: 'Storage class', path: ['StorageClass'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['Contents'],
        keys: [{ path: ['Key'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 's3' }, { const: 'buckets' }, { origin: 'Bucket' }, { const: 'objects' }, { param: 'Key', path: ['Key'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'Delimiter', type: 'string' },
      { default: null, name: 'EncodingType', type: 'string' },
      { default: null, name: 'FetchOwner', type: 'boolean' },
      { default: null, name: 'Prefix', type: 'string' },
      { default: null, name: 'StartAfter', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'objects', '$Key'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'HeadObject',
      {
        Bucket: $.Bucket,
        Key: $.Key,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'objects', '$Key', 'annotations'], a.table.node + aws.regional + aws.paginated + {
    inputToken:: 'ContinuationToken',
    outputToken:: 'NextContinuationToken',
    pageSize:: 'MaxAnnotationResults',
    response:: call(
      self.ctx,
      'ListObjectAnnotations',
      self.page {
        Bucket: $.Bucket,
        Key: $.Key,
        AnnotationPrefix: std.get($._params, 'AnnotationPrefix', null),
        VersionId: std.get($._params, 'VersionId', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['Annotations'],
      columns: [
        { key: 'annotationName', kind: 'name', label: 'Annotation', path: ['AnnotationName'], priority: 'primary' },
        { key: 'replicationStatus', kind: 'status', label: 'Replication', path: ['ReplicationStatus'], priority: 'secondary' },
        { key: 'lastModified', kind: 'timestamp', label: 'Last modified', path: ['LastModified'], priority: 'secondary' },
        { key: 'size', kind: 'number', label: 'Size', path: ['Size'], priority: 'tertiary' },
      ],
    },
    _paramSpecs+: [
      { default: null, name: 'AnnotationPrefix', type: 'string' },
      { default: null, name: 'VersionId', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'objects', '$Key', 'acl'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetObjectAcl',
      {
        Bucket: $.Bucket,
        Key: $.Key,
        VersionId: std.get($._params, 'VersionId', null),
      }
    ),
    _paramSpecs+: [
      { default: null, name: 'VersionId', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'objects', '$Key', 'legalHold'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetObjectLegalHold',
      {
        Bucket: $.Bucket,
        Key: $.Key,
        VersionId: std.get($._params, 'VersionId', null),
      }
    ),
    _paramSpecs+: [
      { default: null, name: 'VersionId', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'objects', '$Key', 'retention'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetObjectRetention',
      {
        Bucket: $.Bucket,
        Key: $.Key,
        VersionId: std.get($._params, 'VersionId', null),
      }
    ),
    _paramSpecs+: [
      { default: null, name: 'VersionId', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'objects', '$Key', 'tagging'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetObjectTagging',
      {
        Bucket: $.Bucket,
        Key: $.Key,
        VersionId: std.get($._params, 'VersionId', null),
      }
    ),
    _paramSpecs+: [
      { default: null, name: 'VersionId', type: 'string' },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'abac'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketAbac',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'accelerateConfiguration'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketAccelerateConfiguration',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'acl'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketAcl',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'cors'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketCors',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'encryption'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketEncryption',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'lifecycleConfiguration'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketLifecycleConfiguration',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'location'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketLocation',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'logging'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketLogging',
      {
        Bucket: $.Bucket,
      }
    ),
    linkSpecs:: [
      {
        at: ['LoggingEnabled'],
        keys: [{ const: 'target bucket' }],
        value: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }, { const: 's3' }, { const: 'buckets' }, { param: 'Bucket', path: ['TargetBucket'] }],
      },
    ],
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'metadataConfiguration'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketMetadataConfiguration',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'metadataTableConfiguration'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketMetadataTableConfiguration',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'notificationConfiguration'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketNotificationConfiguration',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'ownershipControls'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketOwnershipControls',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'policyStatus'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketPolicyStatus',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'policy'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketPolicy',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'replication'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketReplication',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'requestPayment'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketRequestPayment',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'tagging'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketTagging',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'versioning'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketVersioning',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'website'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetBucketWebsite',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'objectLockConfiguration'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetObjectLockConfiguration',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
  [['aws', '$account', '$region', 's3', 'buckets', '$Bucket', 'publicAccessBlock'], a.resource.node + aws.regional + {
    data: call(
      self.ctx,
      'GetPublicAccessBlock',
      {
        Bucket: $.Bucket,
      }
    ),
  }],
]
