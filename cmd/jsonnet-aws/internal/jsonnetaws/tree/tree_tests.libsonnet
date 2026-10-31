local libTreeLib = import 'tree.libsonnet';

local member(target, required=false) =
  { target: target } + (if required then { traits: { 'smithy.api#required': {} } } else {});

local structure(members) = { type: 'structure', members: members };

local list(target) = { type: 'list', member: { target: target } };

local operation(input, output, paginated=null) = {
  type: 'operation',
  input: { target: input },
  output: { target: output },
} + (if paginated == null then {} else { traits: { 'smithy.api#paginated': paginated } });

local pages(items) = { inputToken: 'nextToken', outputToken: 'nextToken', pageSize: 'maxResults', items: items };

local model = {
  shapes: {
    'demo#Demo': {
      type: 'service',
      operations: [
        { target: 'demo#' + name }
        for name in [
          'ListWidgets',
          'DescribeWidgets',
          'GetWidget',
          'BatchGetWidgets',
          'ListGizmos',
          'GetWidgetPolicy',
          'GetSettings',
          'ListOrphans',
          'DescribeWidgetHistory',
        ]
      ],
    },
    'demo#String': { type: 'string' },
    'demo#Timestamp': { type: 'timestamp' },
    'demo#Count': { type: 'integer' },
    'demo#Widget': structure({
      widgetName: member('demo#String'),
      status: member('demo#String'),
      createdAt: member('demo#Timestamp'),
      tags: member('demo#Names'),
    }),
    'demo#Widgets': list('demo#Widget'),
    'demo#Names': list('demo#String'),
    'demo#Gizmo': structure({ gizmoId: member('demo#String') }),
    'demo#Gizmos': list('demo#Gizmo'),
    'demo#ListWidgets': operation('demo#ListWidgetsRequest', 'demo#ListWidgetsResponse', pages('widgets')),
    'demo#ListWidgetsRequest': structure({ nextToken: member('demo#String'), maxResults: member('demo#Count') }),
    'demo#ListWidgetsResponse': structure({ nextToken: member('demo#String'), widgets: member('demo#Widgets') }),
    'demo#DescribeWidgets': operation('demo#DescribeWidgetsRequest', 'demo#DescribeWidgetsResponse', pages('widgets')),
    'demo#DescribeWidgetsRequest': structure({
      nextToken: member('demo#String'),
      maxResults: member('demo#Count'),
      widgetNames: member('demo#Names'),
      owner: member('demo#String'),
    }),
    'demo#DescribeWidgetsResponse': structure({ nextToken: member('demo#String'), widgets: member('demo#Widgets') }),
    'demo#GetWidget': operation('demo#WidgetRequest', 'demo#Widget'),
    'demo#WidgetRequest': structure({ widgetName: member('demo#String', true) }),
    'demo#BatchGetWidgets': operation('demo#BatchRequest', 'demo#DescribeWidgetsResponse'),
    'demo#BatchRequest': structure({ widgetNames: member('demo#Names', true) }),
    'demo#ListGizmos': operation('demo#WidgetRequest', 'demo#GizmosResponse'),
    'demo#GizmosResponse': structure({ gizmos: member('demo#Gizmos') }),
    'demo#GetWidgetPolicy': operation('demo#WidgetRequest', 'demo#Widget'),
    'demo#GetSettings': operation('smithy.api#Unit', 'demo#Widget'),
    'demo#ListOrphans': operation('demo#OrphansRequest', 'demo#GizmosResponse'),
    'demo#OrphansRequest': structure({ orphanKey: member('demo#String', true) }),
    'demo#Entry': structure({ message: member('demo#String'), loggedAt: member('demo#Timestamp') }),
    'demo#Entries': list('demo#Entry'),
    'demo#History': structure({ entries: member('demo#Entries'), total: member('demo#Count') }),
    'demo#DescribeWidgetHistory': operation('demo#WidgetHistoryRequest', 'demo#WidgetHistoryResponse', { inputToken: 'nextToken', outputToken: 'nextToken', pageSize: 'maxResults' }),
    'demo#WidgetHistoryRequest': structure({ widgetName: member('demo#String', true), nextToken: member('demo#String'), maxResults: member('demo#Count') }),
    'demo#WidgetHistoryResponse': structure({ widgetName: member('demo#String'), history: member('demo#History'), nextToken: member('demo#String') }),
  },
};

local treeOf(resources={}, columns=[]) =
  libTreeLib {
    model:: model,
    overrides:: resources,
    columns:: columns,
  };

local outline(node) =
  {
    [c.segment]: {
      operation: c.name,
      id: if c.id == null then null else c.id.param,
      detail: if c.id == null then null else std.get(c.id, 'detail', std.get(c.id, 'filter', null)),
      children: if c.children == null then null else outline(c.children),
    }
    for c in node.collections
  } + {
    [s.segment]: s.name
    for s in node.singletons
  };

{
  output(input):: input(),
  tests: [
    {
      name: 'places collections, details, children and singletons from the model',
      input:: function()
        local tree = treeOf();
        {
          outline: outline(tree.root),
          superseded: tree.superseded,
          unplaced: tree.unplaced,
        },
      expected: {
        outline: {
          widgets: {
            operation: 'DescribeWidgets',
            id: 'widgetName',
            detail: 'GetWidget',
            children: {
              gizmos: { operation: 'ListGizmos', id: 'gizmoId', detail: null, children: {} },
              history: { operation: 'DescribeWidgetHistory', id: null, detail: null, children: null },
              policy: 'GetWidgetPolicy',
            },
          },
          settings: 'GetSettings',
        },
        superseded: ['ListWidgets'],
        unplaced: ['ListOrphans'],
      },
    },
    {
      name: 'uses the plural list filter as detail when there is no get operation',
      input:: function()
        local id = treeOf({ operations: { GetWidget: { skip: true } } }).root.collections[0].id;
        { param: id.param, filter: id.filter, input: id.input },
      expected: {
        param: 'widgetName',
        filter: 'widgetNames',
        input: { widgetName: { param: 'widgetName' } },
      },
    },
    {
      name: 'overrides rename, skip and identify operations',
      input:: function()
        local tree = treeOf({
          operations: {
            GetSettings: { name: 'configuration' },
            GetWidgetPolicy: { skip: true },
            ListOrphans: { skip: true },
          },
        });
        {
          outline: outline(tree.root),
          unplaced: tree.unplaced,
        },
      expected: {
        outline: {
          widgets: {
            operation: 'DescribeWidgets',
            id: 'widgetName',
            detail: 'GetWidget',
            children: {
              gizmos: { operation: 'ListGizmos', id: 'gizmoId', detail: null, children: {} },
              history: { operation: 'DescribeWidgetHistory', id: null, detail: null, children: null },
            },
          },
          configuration: 'GetSettings',
        },
        unplaced: [],
      },
    },
    {
      name: 'collection params, pagination and default columns',
      input:: function()
        local widgets = treeOf().root.collections[0];
        {
          params: widgets.params,
          paginated: widgets.paginated,
          itemsPath: widgets.itemsPath,
          columns: widgets.columns,
        },
      expected: {
        params: [{ name: 'owner', type: 'string' }],
        paginated: { inputToken: 'nextToken', outputToken: 'nextToken', pageSize: 'maxResults' },
        itemsPath: ['widgets'],
        columns: [
          { label: 'Widget name', path: ['widgetName'] },
          { label: 'Status', path: ['status'] },
          { label: 'Created at', path: ['createdAt'] },
        ],
      },
    },
    {
      name: 'explicit columns replace the default columns',
      input:: function()
        treeOf(columns=[{ operation: 'DescribeWidgets', columns: [{ label: 'Name', path: ['widgetName'] }] }]).root.collections[0].columns,
      expected: [{ label: 'Name', path: ['widgetName'] }],
    },
    {
      name: 'paginated operations without an items path list their single nested list',
      input:: function()
        local history = treeOf().root.collections[0].children.collections[1];
        { operation: history.name, itemsPath: history.itemsPath, paginated: history.paginated != null },
      expected: { operation: 'DescribeWidgetHistory', itemsPath: ['history', 'entries'], paginated: true },
    },
    {
      name: 'paginated operations with several nested lists are reported as ambiguous',
      input:: function()
        local tree = treeOf() {
          model+:: { shapes+: { 'demo#History'+: { members+: { archived: member('demo#Entries') } } } },
        };
        tree.ambiguousItems,
      expected: [{ operation: 'DescribeWidgetHistory', candidates: [['history', 'archived'], ['history', 'entries']] }],
    },
    {
      name: 'items override wins over the inferred items path',
      input:: function()
        treeOf({ operations: { DescribeWidgets: { items: ['widgets'] } } }).root.collections[0].itemsPath,
      expected: ['widgets'],
    },
    {
      name: 'hidden params are not exposed',
      input:: function()
        treeOf({ hiddenParams: ['owner'] }).root.collections[0].params,
      expected: [],
    },
    {
      name: 'empty explicit columns fall back to the default columns',
      input:: function()
        std.length(treeOf(columns=[{ operation: 'DescribeWidgets', columns: [] }]).root.collections[0].columns),
      expected: 3,
    },
  ],
}
