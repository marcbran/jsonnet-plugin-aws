local a = import 'arcourse-ui/main.libsonnet',
      aws = import 'mixins.libsonnet',
      root = import 'root',
      call(ctx, operation, input) = std.native('invoke:aws')('call', [ctx, 'iam', operation, input]);

[
  [['aws', '$account'], {
    links+: {
      IAM: root.aws.account($.account).iam,
    },
  }],
  [['aws', '$account', 'iam']],
  [['aws', '$account', 'iam', 'accountAliases'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListAccountAliases',
      self.page
    ),
    data:: self.response,
    table:: {
      at: ['AccountAliases'],
      columns: [
        { key: 'alias', kind: 'name', label: 'Alias', path: [], priority: 'primary' },
      ],
    },
  }],
  [['aws', '$account', 'iam', 'groups'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListGroups',
      self.page {
        PathPrefix: std.get($._params, 'PathPrefix', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['Groups'],
      columns: [
        { key: 'groupName', kind: 'name', label: 'Group name', path: ['GroupName'], priority: 'primary' },
        { key: 'groupId', kind: 'identifier', label: 'Group ID', path: ['GroupId'], priority: 'secondary' },
        { key: 'createDate', kind: 'timestamp', label: 'Created', path: ['CreateDate'], priority: 'secondary' },
        { key: 'path', kind: 'text', label: 'Path', path: ['Path'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['Groups'],
        keys: [{ path: ['GroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'groups' }, { param: 'GroupName', path: ['GroupName'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'PathPrefix', type: 'string' },
    ],
  }],
  [['aws', '$account', 'iam', 'groups', '$GroupName']],
  [['aws', '$account', 'iam', 'groups', '$GroupName', 'attachedGroupPolicies'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListAttachedGroupPolicies',
      self.page {
        GroupName: $.GroupName,
        PathPrefix: std.get($._params, 'PathPrefix', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['AttachedPolicies'],
      columns: [
        { key: 'policyName', kind: 'name', label: 'Policy name', path: ['PolicyName'], priority: 'primary' },
        { key: 'policyArn', kind: 'identifier', label: 'Policy ARN', path: ['PolicyArn'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['AttachedPolicies'],
        keys: [{ const: 'policy' }, { path: ['PolicyArn'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { param: 'PolicyArn', path: ['PolicyArn'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'PathPrefix', type: 'string' },
    ],
  }],
  [['aws', '$account', 'iam', 'groups', '$GroupName', 'policies'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListGroupPolicies',
      self.page {
        GroupName: $.GroupName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['PolicyNames'],
      columns: [
        { key: 'policyName', kind: 'name', label: 'Policy Name', path: [], priority: 'primary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['PolicyNames'],
        keys: [{ path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'groups' }, { origin: 'GroupName' }, { const: 'policies' }, { param: 'PolicyName', path: [] }],
      },
    ],
  }],
  [['aws', '$account', 'iam', 'groups', '$GroupName', 'policies', '$PolicyName'], a.resource.node + aws.global + {
    response:: call(
      self.ctx,
      'GetGroupPolicy',
      {
        GroupName: $.GroupName,
        PolicyName: $.PolicyName,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', 'iam', 'groups', '$GroupName', 'users'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'GetGroup',
      self.page {
        GroupName: $.GroupName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['Users'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'userName', kind: 'name', label: 'User name', path: ['UserName'], priority: 'primary' },
        { key: 'userId', kind: 'identifier', label: 'User ID', path: ['UserId'], priority: 'secondary' },
        { key: 'createDate', kind: 'timestamp', label: 'Created', path: ['CreateDate'], priority: 'secondary' },
        { key: 'passwordLastUsed', kind: 'timestamp', label: 'Password last used', path: ['PasswordLastUsed'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['Users'],
        keys: [{ const: 'permissions boundary' }, { path: ['UserName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { param: 'PolicyArn', path: ['PermissionsBoundary', 'PermissionsBoundaryArn'] }],
      },
    ],
  }],
  [['aws', '$account', 'iam', 'instanceProfiles'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListInstanceProfiles',
      self.page {
        PathPrefix: std.get($._params, 'PathPrefix', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['InstanceProfiles'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'instanceProfileName', kind: 'name', label: 'Profile name', path: ['InstanceProfileName'], priority: 'primary' },
        { key: 'createDate', kind: 'timestamp', label: 'Created', path: ['CreateDate'], priority: 'secondary' },
        { key: 'path', kind: 'text', label: 'Path', path: ['Path'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['InstanceProfiles'],
        keys: [{ path: ['InstanceProfileName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'instanceProfiles' }, { param: 'InstanceProfileName', path: ['InstanceProfileName'] }],
      },
      {
        at: ['InstanceProfiles', 'Roles'],
        keys: [{ const: 'role' }, { path: ['RoleName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'roles' }, { param: 'RoleName', path: ['RoleName'] }],
      },
      {
        at: ['InstanceProfiles', 'Roles', 'PermissionsBoundary'],
        keys: [{ const: 'permissions boundary' }, { path: ['PermissionsBoundaryArn'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { param: 'PolicyArn', path: ['PermissionsBoundaryArn'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'PathPrefix', type: 'string' },
    ],
  }],
  [['aws', '$account', 'iam', 'instanceProfiles', '$InstanceProfileName'], a.resource.node + aws.global + {
    response:: call(
      self.ctx,
      'GetInstanceProfile',
      {
        InstanceProfileName: $.InstanceProfileName,
      }
    ),
    data: self.response,
    linkSpecs:: [
      {
        at: ['InstanceProfile', 'Roles'],
        keys: [{ const: 'role' }, { path: ['RoleName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'roles' }, { param: 'RoleName', path: ['RoleName'] }],
      },
      {
        at: ['InstanceProfile', 'Roles'],
        keys: [{ const: 'permissions boundary' }, { path: ['RoleName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { param: 'PolicyArn', path: ['PermissionsBoundary', 'PermissionsBoundaryArn'] }],
      },
    ],
  }],
  [['aws', '$account', 'iam', 'instanceProfiles', '$InstanceProfileName', 'tags'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListInstanceProfileTags',
      self.page {
        InstanceProfileName: $.InstanceProfileName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['Tags'],
      columns: [
        { key: 'key', kind: 'name', label: 'Key', path: ['Key'], priority: 'primary' },
        { key: 'value', kind: 'text', label: 'Value', path: ['Value'], priority: 'secondary' },
      ],
    },
  }],
  [['aws', '$account', 'iam', 'openIDConnectProviders'], a.table.node + aws.global + {
    response:: call(
      self.ctx,
      'ListOpenIDConnectProviders',
      {}
    ),
    data:: self.response,
    table:: {
      at: ['OpenIDConnectProviderList'],
      columns: [
        { key: 'arn', kind: 'identifier', label: 'Provider ARN', path: ['Arn'], priority: 'primary' },
      ],
    },
  }],
  [['aws', '$account', 'iam', 'policies'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListPolicies',
      self.page {
        OnlyAttached: std.get($._params, 'OnlyAttached', null),
        PathPrefix: std.get($._params, 'PathPrefix', null),
        PolicyUsageFilter: std.get($._params, 'PolicyUsageFilter', null),
        Scope: std.get($._params, 'Scope', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['Policies'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'policyName', kind: 'name', label: 'Policy name', path: ['PolicyName'], priority: 'primary' },
        { key: 'attachmentCount', kind: 'count', label: 'Attachments', path: ['AttachmentCount'], priority: 'secondary' },
        { key: 'updateDate', kind: 'timestamp', label: 'Updated', path: ['UpdateDate'], priority: 'secondary' },
        { key: 'isAttachable', kind: 'boolean', label: 'Attachable', path: ['IsAttachable'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['Policies'],
        keys: [{ path: ['Arn'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { param: 'PolicyArn', path: ['Arn'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'OnlyAttached', type: 'boolean' },
      { default: null, name: 'PathPrefix', type: 'string' },
      { default: null, name: 'PolicyUsageFilter', type: 'string' },
      { default: null, name: 'Scope', type: 'string' },
    ],
  }],
  [['aws', '$account', 'iam', 'policies', '$PolicyArn'], a.resource.node + aws.global + {
    response:: call(
      self.ctx,
      'GetPolicy',
      {
        PolicyArn: $.PolicyArn,
      }
    ),
    data: self.response,
    linkSpecs:: [
      {
        at: ['Policy'],
        keys: [{ const: 'default version' }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { param: 'PolicyArn', path: ['Arn'] }, { const: 'versions' }, { param: 'VersionId', path: ['DefaultVersionId'] }],
      },
    ],
  }],
  [['aws', '$account', 'iam', 'policies', '$PolicyArn', 'tags'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListPolicyTags',
      self.page {
        PolicyArn: $.PolicyArn,
      }
    ),
    data:: self.response,
    table:: {
      at: ['Tags'],
      columns: [
        { key: 'key', kind: 'text', label: 'Key', path: ['Key'], priority: 'primary' },
        { key: 'value', kind: 'text', label: 'Value', path: ['Value'], priority: 'secondary' },
      ],
    },
  }],
  [['aws', '$account', 'iam', 'policies', '$PolicyArn', 'versions'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListPolicyVersions',
      self.page {
        PolicyArn: $.PolicyArn,
      }
    ),
    data:: self.response,
    table:: {
      at: ['Versions'],
      columns: [
        { key: 'versionId', kind: 'identifier', label: 'Version ID', path: ['VersionId'], priority: 'primary' },
        { key: 'isDefaultVersion', kind: 'boolean', label: 'Default', path: ['IsDefaultVersion'], priority: 'secondary' },
        { key: 'createDate', kind: 'timestamp', label: 'Created', path: ['CreateDate'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['Versions'],
        keys: [{ path: ['VersionId'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { origin: 'PolicyArn' }, { const: 'versions' }, { param: 'VersionId', path: ['VersionId'] }],
      },
    ],
  }],
  [['aws', '$account', 'iam', 'policies', '$PolicyArn', 'versions', '$VersionId'], a.resource.node + aws.global + {
    response:: call(
      self.ctx,
      'GetPolicyVersion',
      {
        PolicyArn: $.PolicyArn,
        VersionId: $.VersionId,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', 'iam', 'policies', '$PolicyArn', 'entities'], a.resource.node + aws.global + {
    response:: call(
      self.ctx,
      'ListEntitiesForPolicy',
      {
        PolicyArn: $.PolicyArn,
        EntityFilter: std.get($._params, 'EntityFilter', null),
        PathPrefix: std.get($._params, 'PathPrefix', null),
        PolicyUsageFilter: std.get($._params, 'PolicyUsageFilter', null),
      }
    ),
    data: self.response,
    linkSpecs:: [
      {
        at: ['PolicyGroups'],
        keys: [{ const: 'group' }, { path: ['GroupName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'groups' }, { param: 'GroupName', path: ['GroupName'] }],
      },
      {
        at: ['PolicyRoles'],
        keys: [{ const: 'role' }, { path: ['RoleName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'roles' }, { param: 'RoleName', path: ['RoleName'] }],
      },
      {
        at: ['PolicyUsers'],
        keys: [{ const: 'user' }, { path: ['UserName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'users' }, { param: 'UserName', path: ['UserName'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'EntityFilter', type: 'string' },
      { default: null, name: 'PathPrefix', type: 'string' },
      { default: null, name: 'PolicyUsageFilter', type: 'string' },
    ],
  }],
  [['aws', '$account', 'iam', 'roles'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListRoles',
      self.page {
        PathPrefix: std.get($._params, 'PathPrefix', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['Roles'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'role_name', kind: 'name', label: 'Role name', path: ['RoleName'], priority: 'primary' },
        { key: 'path', kind: 'text', label: 'Path', path: ['Path'], priority: 'secondary' },
        { key: 'create_date', kind: 'timestamp', label: 'Created', path: ['CreateDate'], priority: 'secondary' },
        { key: 'last_used', kind: 'timestamp', label: 'Last used', path: ['RoleLastUsed', 'LastUsedDate'], priority: 'secondary' },
        { key: 'max_session_duration', kind: 'number', label: 'Max session (s)', path: ['MaxSessionDuration'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['Roles'],
        keys: [{ path: ['RoleName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'roles' }, { param: 'RoleName', path: ['RoleName'] }],
      },
      {
        at: ['Roles'],
        keys: [{ const: 'permissions boundary' }, { path: ['RoleName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { param: 'PolicyArn', path: ['PermissionsBoundary', 'PermissionsBoundaryArn'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'PathPrefix', type: 'string' },
    ],
  }],
  [['aws', '$account', 'iam', 'roles', '$RoleName'], a.resource.node + aws.global + {
    response:: call(
      self.ctx,
      'GetRole',
      {
        RoleName: $.RoleName,
      }
    ),
    data: self.response,
    linkSpecs:: [
      {
        at: ['Role'],
        keys: [{ const: 'permissions boundary' }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { param: 'PolicyArn', path: ['PermissionsBoundary', 'PermissionsBoundaryArn'] }],
      },
    ],
  }],
  [['aws', '$account', 'iam', 'roles', '$RoleName', 'attachedRolePolicies'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListAttachedRolePolicies',
      self.page {
        RoleName: $.RoleName,
        PathPrefix: std.get($._params, 'PathPrefix', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['AttachedPolicies'],
      columns: [
        { key: 'policyName', kind: 'name', label: 'Policy name', path: ['PolicyName'], priority: 'primary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['AttachedPolicies'],
        keys: [{ const: 'policy' }, { path: ['PolicyArn'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { param: 'PolicyArn', path: ['PolicyArn'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'PathPrefix', type: 'string' },
    ],
  }],
  [['aws', '$account', 'iam', 'roles', '$RoleName', 'instanceProfilesForRole'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListInstanceProfilesForRole',
      self.page {
        RoleName: $.RoleName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['InstanceProfiles'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'name', kind: 'name', label: 'Profile name', path: ['InstanceProfileName'], priority: 'primary' },
        { key: 'path', kind: 'text', label: 'Path', path: ['Path'], priority: 'secondary' },
        { key: 'created', kind: 'timestamp', label: 'Created', path: ['CreateDate'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['InstanceProfiles', 'Roles'],
        keys: [{ const: 'permissions boundary' }, { path: ['RoleName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { param: 'PolicyArn', path: ['PermissionsBoundary', 'PermissionsBoundaryArn'] }],
      },
    ],
  }],
  [['aws', '$account', 'iam', 'roles', '$RoleName', 'policies'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListRolePolicies',
      self.page {
        RoleName: $.RoleName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['PolicyNames'],
      columns: [
        { key: 'policyName', kind: 'name', label: 'Policy name', path: [], priority: 'primary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['PolicyNames'],
        keys: [{ path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'roles' }, { origin: 'RoleName' }, { const: 'policies' }, { param: 'PolicyName', path: [] }],
      },
    ],
  }],
  [['aws', '$account', 'iam', 'roles', '$RoleName', 'policies', '$PolicyName'], a.resource.node + aws.global + {
    response:: call(
      self.ctx,
      'GetRolePolicy',
      {
        PolicyName: $.PolicyName,
        RoleName: $.RoleName,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', 'iam', 'roles', '$RoleName', 'tags'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListRoleTags',
      self.page {
        RoleName: $.RoleName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['Tags'],
      columns: [
        { key: 'key', kind: 'name', label: 'Key', path: ['Key'], priority: 'primary' },
        { key: 'value', kind: 'text', label: 'Value', path: ['Value'], priority: 'secondary' },
      ],
    },
  }],
  [['aws', '$account', 'iam', 'samlProviders'], a.table.node + aws.global + {
    response:: call(
      self.ctx,
      'ListSAMLProviders',
      {}
    ),
    data:: self.response,
    table:: {
      at: ['SAMLProviderList'],
      columns: [
        { key: 'arn', kind: 'identifier', label: 'ARN', path: ['Arn'], priority: 'primary' },
        { key: 'createDate', kind: 'timestamp', label: 'Created', path: ['CreateDate'], priority: 'secondary' },
        { key: 'validUntil', kind: 'timestamp', label: 'Valid Until', path: ['ValidUntil'], priority: 'secondary' },
      ],
    },
  }],
  [['aws', '$account', 'iam', 'users'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListUsers',
      self.page {
        PathPrefix: std.get($._params, 'PathPrefix', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['Users'],
      columns: [
        { label: 'Name', value:: aws.tag('Name') },
        { key: 'UserName', kind: 'name', label: 'User name', path: ['UserName'], priority: 'primary' },
        { key: 'UserId', kind: 'identifier', label: 'User ID', path: ['UserId'], priority: 'secondary' },
        { key: 'CreateDate', kind: 'timestamp', label: 'Created', path: ['CreateDate'], priority: 'secondary' },
        { key: 'PasswordLastUsed', kind: 'timestamp', label: 'Password last used', path: ['PasswordLastUsed'], priority: 'tertiary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['Users'],
        keys: [{ path: ['UserName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'users' }, { param: 'UserName', path: ['UserName'] }],
      },
      {
        at: ['Users'],
        keys: [{ const: 'permissions boundary' }, { path: ['UserName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { param: 'PolicyArn', path: ['PermissionsBoundary', 'PermissionsBoundaryArn'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'PathPrefix', type: 'string' },
    ],
  }],
  [['aws', '$account', 'iam', 'users', '$UserName'], a.resource.node + aws.global + {
    response:: call(
      self.ctx,
      'GetUser',
      {
        UserName: $.UserName,
      }
    ),
    data: self.response,
    linkSpecs:: [
      {
        at: ['User', 'PermissionsBoundary'],
        keys: [{ const: 'permissions boundary' }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { param: 'PolicyArn', path: ['PermissionsBoundaryArn'] }],
      },
    ],
  }],
  [['aws', '$account', 'iam', 'users', '$UserName', 'attachedUserPolicies'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListAttachedUserPolicies',
      self.page {
        UserName: $.UserName,
        PathPrefix: std.get($._params, 'PathPrefix', null),
      }
    ),
    data:: self.response,
    table:: {
      at: ['AttachedPolicies'],
      columns: [
        { key: 'PolicyName', kind: 'name', label: 'Policy name', path: ['PolicyName'], priority: 'primary' },
        { key: 'PolicyArn', kind: 'identifier', label: 'Policy ARN', path: ['PolicyArn'], priority: 'secondary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['AttachedPolicies'],
        keys: [{ const: 'policy' }, { path: ['PolicyName'] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'policies' }, { param: 'PolicyArn', path: ['PolicyArn'] }],
      },
    ],
    _paramSpecs+: [
      { default: null, name: 'PathPrefix', type: 'string' },
    ],
  }],
  [['aws', '$account', 'iam', 'users', '$UserName', 'groupsForUser'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListGroupsForUser',
      self.page {
        UserName: $.UserName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['Groups'],
      columns: [
        { key: 'groupName', kind: 'name', label: 'Group name', path: ['GroupName'], priority: 'primary' },
        { key: 'groupId', kind: 'identifier', label: 'Group ID', path: ['GroupId'], priority: 'secondary' },
        { key: 'path', kind: 'text', label: 'Path', path: ['Path'], priority: 'secondary' },
        { key: 'createDate', kind: 'timestamp', label: 'Created', path: ['CreateDate'], priority: 'tertiary' },
      ],
    },
  }],
  [['aws', '$account', 'iam', 'users', '$UserName', 'policies'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListUserPolicies',
      self.page {
        UserName: $.UserName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['PolicyNames'],
      columns: [
        { key: 'policyName', kind: 'name', label: 'Policy name', path: [], priority: 'primary' },
      ],
    },
    linkSpecs:: [
      {
        at: ['PolicyNames'],
        keys: [{ path: [] }],
        value: [{ const: 'aws' }, { origin: 'account' }, { const: 'iam' }, { const: 'users' }, { origin: 'UserName' }, { const: 'policies' }, { param: 'PolicyName', path: [] }],
      },
    ],
  }],
  [['aws', '$account', 'iam', 'users', '$UserName', 'policies', '$PolicyName'], a.resource.node + aws.global + {
    response:: call(
      self.ctx,
      'GetUserPolicy',
      {
        PolicyName: $.PolicyName,
        UserName: $.UserName,
      }
    ),
    data: self.response,
  }],
  [['aws', '$account', 'iam', 'users', '$UserName', 'tags'], a.table.node + aws.global + aws.paginated + {
    inputToken:: 'Marker',
    outputToken:: 'Marker',
    pageSize:: 'MaxItems',
    response:: call(
      self.ctx,
      'ListUserTags',
      self.page {
        UserName: $.UserName,
      }
    ),
    data:: self.response,
    table:: {
      at: ['Tags'],
      columns: [
        { key: 'key', kind: 'name', label: 'Key', path: ['Key'], priority: 'primary' },
        { key: 'value', kind: 'text', label: 'Value', path: ['Value'], priority: 'secondary' },
      ],
    },
  }],
  [['aws', '$account', 'iam', 'accountSummary'], a.resource.node + aws.global + {
    response:: call(
      self.ctx,
      'GetAccountSummary',
      {}
    ),
    data: self.response,
  }],
]
