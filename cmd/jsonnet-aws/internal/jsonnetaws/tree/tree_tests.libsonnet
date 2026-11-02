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
          'DescribeMachines',
          'ListRacks',
          'ListBooks',
          'ListBooksV2',
          'GetRackAcl',
          'HeadRack',
          'ListRackAlarms',
          'ListRackSensors',
          'GetRackAlarm',
          'GetRackSensor',
          'ListRackEvents',
          'ListCrateNames',
          'DescribeCrate',
          'DescribeDBTanks',
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
    'demo#Tag': structure({ Key: member('demo#String'), Value: member('demo#String') }),
    'demo#Rack': structure({ Name: member('demo#String'), Region: member('demo#String') }),
    'demo#Racks': list('demo#Rack'),
    'demo#ListRacks': operation('demo#ListRacksRequest', 'demo#ListRacksResponse'),
    'demo#ListRacksRequest': structure({ RackRegion: member('demo#String'), Prefix: member('demo#String') }),
    'demo#ListRacksResponse': structure({ Racks: member('demo#Racks') }),
    'demo#Book': structure({ Title: member('demo#String') }),
    'demo#Books': list('demo#Book'),
    'demo#ListBooksResponse': structure({ Books: member('demo#Books') }),
    'demo#ListBooks': operation('demo#RackRequest', 'demo#ListBooksResponse'),
    'demo#ListBooksV2': operation('demo#RackRequest', 'demo#ListBooksResponse'),
    'demo#GetRackAcl': operation('demo#RackRequest', 'demo#Rack'),
    'demo#HeadRack': operation('demo#RackRequest', 'demo#Rack'),
    'demo#RackRequest': structure({ Rack: member('demo#String', true) }),
    'demo#Config': structure({ Id: member('demo#String') }),
    'demo#Configs': list('demo#Config'),
    'demo#ConfigsResponse': structure({ Configs: member('demo#Configs') }),
    'demo#ListRackAlarms': operation('demo#RackRequest', 'demo#ConfigsResponse'),
    'demo#ListRackSensors': operation('demo#RackRequest', 'demo#ConfigsResponse'),
    'demo#GetRackAlarm': operation('demo#RackConfigRequest', 'demo#Config'),
    'demo#GetRackSensor': operation('demo#RackConfigRequest', 'demo#Config'),
    'demo#RackConfigRequest': structure({ Rack: member('demo#String', true), Id: member('demo#String', true) }),
    'demo#ListRackEvents': operation('demo#RackRequest', 'demo#RackEventsResponse'),
    'demo#RackEventsResponse': structure({ Events: member('demo#Configs'), Warnings: member('demo#Configs'), Marker: member('demo#String') }),
    'demo#CrateInfo': structure({ CrateName: member('demo#String'), Kind: member('demo#String') }),
    'demo#CrateInfos': list('demo#CrateInfo'),
    'demo#ListCrateNames': operation('smithy.api#Unit', 'demo#ListCrateNamesResponse'),
    'demo#ListCrateNamesResponse': structure({ CrateNames: member('demo#CrateInfos') }),
    'demo#DescribeCrate': operation('demo#CrateRequest', 'demo#CrateInfo'),
    'demo#CrateRequest': structure({ CrateName: member('demo#String', true) }),
    'demo#DBTank': structure({ DBTankIdentifier: member('demo#String'), Engine: member('demo#String') }),
    'demo#DBTanks': list('demo#DBTank'),
    'demo#DescribeDBTanks': operation('demo#DescribeDBTanksRequest', 'demo#DescribeDBTanksResponse'),
    'demo#DescribeDBTanksRequest': structure({ DBTankIdentifier: member('demo#String') }),
    'demo#DescribeDBTanksResponse': structure({ DBTanks: member('demo#DBTanks') }),
    'demo#Tags': list('demo#Tag'),
    'demo#Machine': structure({ MachineId: member('demo#String'), State: member('demo#String'), Tags: member('demo#Tags') }),
    'demo#Machines': list('demo#Machine'),
    'demo#Reservation': structure({ ReservationId: member('demo#String'), Machines: member('demo#Machines') }),
    'demo#Reservations': list('demo#Reservation'),
    'demo#DescribeMachines': operation('demo#DescribeMachinesRequest', 'demo#DescribeMachinesResponse', { inputToken: 'NextToken', outputToken: 'NextToken', pageSize: 'MaxResults', items: 'Reservations' }),
    'demo#DescribeMachinesRequest': structure({ MachineIds: member('demo#Names'), NextToken: member('demo#String'), MaxResults: member('demo#Count') }),
    'demo#DescribeMachinesResponse': structure({ Reservations: member('demo#Reservations'), NextToken: member('demo#String') }),
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

local widgets(tree) = [c for c in tree.root.collections if c.name == 'DescribeWidgets'][0];

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
          crates: { operation: 'ListCrateNames', id: 'CrateName', detail: 'DescribeCrate', children: {} },
          dbTanks: { operation: 'DescribeDBTanks', id: 'DBTankIdentifier', detail: 'DBTankIdentifier', children: {} },
          machines: { operation: 'DescribeMachines', id: 'MachineId', detail: 'MachineIds', children: {} },
          racks: {
            operation: 'ListRacks',
            id: 'Rack',
            detail: 'HeadRack',
            children: {
              acl: 'GetRackAcl',
              events: 'ListRackEvents',
              alarms: { operation: 'ListRackAlarms', id: 'Id', detail: 'GetRackAlarm', children: {} },
              books: { operation: 'ListBooksV2', id: null, detail: null, children: null },
              sensors: { operation: 'ListRackSensors', id: 'Id', detail: 'GetRackSensor', children: {} },
            },
          },
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
        superseded: ['ListBooks', 'ListWidgets'],
        unplaced: ['ListOrphans'],
      },
    },
    {
      name: 'uses the plural list filter as detail when there is no get operation',
      input:: function()
        local id = widgets(treeOf({ operations: { GetWidget: { skip: true } } })).id;
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
          crates: { operation: 'ListCrateNames', id: 'CrateName', detail: 'DescribeCrate', children: {} },
          dbTanks: { operation: 'DescribeDBTanks', id: 'DBTankIdentifier', detail: 'DBTankIdentifier', children: {} },
          machines: { operation: 'DescribeMachines', id: 'MachineId', detail: 'MachineIds', children: {} },
          racks: {
            operation: 'ListRacks',
            id: 'Rack',
            detail: 'HeadRack',
            children: {
              acl: 'GetRackAcl',
              events: 'ListRackEvents',
              alarms: { operation: 'ListRackAlarms', id: 'Id', detail: 'GetRackAlarm', children: {} },
              books: { operation: 'ListBooksV2', id: null, detail: null, children: null },
              sensors: { operation: 'ListRackSensors', id: 'Id', detail: 'GetRackSensor', children: {} },
            },
          },
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
        local collection = widgets(treeOf());
        {
          params: collection.params,
          paginated: collection.paginated,
          itemsPath: collection.itemsPath,
          columns: collection.columns,
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
        widgets(treeOf(columns=[{ operation: 'DescribeWidgets', columns: [{ label: 'Name', path: ['widgetName'] }] }])).columns,
      expected: [{ label: 'Name', path: ['widgetName'] }],
    },
    {
      name: 'paginated operations without an items path list their single nested list',
      input:: function()
        local history = [c for c in widgets(treeOf()).children.collections if c.name == 'DescribeWidgetHistory'][0];
        { operation: history.name, itemsPath: history.itemsPath, paginated: history.paginated != null },
      expected: { operation: 'DescribeWidgetHistory', itemsPath: ['history', 'entries'], paginated: true },
    },
    {
      name: 'paginated operations with several nested lists are reported as ambiguous',
      input:: function()
        local tree = treeOf() {
          model+:: { shapes+: { 'demo#History'+: { members+: { archived: member('demo#Entries') } } } },
        };
        [a for a in tree.ambiguousItems if a.operation == 'DescribeWidgetHistory'],
      expected: [{ operation: 'DescribeWidgetHistory', candidates: [['history', 'archived'], ['history', 'entries']] }],
    },
    {
      name: 'include keeps the named top-level operations and everything below them',
      input:: function()
        local tree = treeOf({ include: ['DescribeWidgets', 'ListOrphans'] });
        { outline: outline(tree.root), unplaced: tree.unplaced },
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
        },
        unplaced: ['ListOrphans'],
      },
    },
    {
      name: 'operations outside include are not reported as unplaced',
      input:: function()
        treeOf({ include: ['DescribeWidgets'] }).unplaced,
      expected: [],
    },
    {
      name: 'paged wrapper items holding a list named like the operation are flattened to that list',
      input:: function()
        local machines = [c for c in treeOf().root.collections if c.name == 'DescribeMachines'][0];
        { itemsPath: machines.itemsPath, flatten: machines.itemsFlatten, id: machines.id.param, filter: machines.id.filter },
      expected: { itemsPath: ['Reservations', 'Machines'], flatten: true, id: 'MachineId', filter: 'MachineIds' },
    },
    {
      name: 'items with EC2-style tags get a Name column first',
      input:: function()
        local machines = [c for c in treeOf().root.collections if c.name == 'DescribeMachines'][0];
        machines.columns[0],
      expected: { label: 'Name', tag: 'Name' },
    },
    {
      name: 'children taking the singular noun as input are fed by the item identifier',
      input:: function()
        local racks = [c for c in treeOf({ include: ['ListRacks'] }).root.collections if c.name == 'ListRacks'][0];
        {
          id: racks.id,
          children: [c.name + ' ' + c.segment for c in racks.children.collections] + [s.name + ' ' + s.segment for s in racks.children.singletons],
        },
      expected: {
        id: { param: 'Rack', path: ['Name'], input: { Rack: { param: 'Rack' } }, detail: 'HeadRack' },
        children: ['ListBooksV2 books', 'ListRackAlarms alarms', 'ListRackSensors sensors', 'GetRackAcl acl', 'ListRackEvents events'],
      },
    },
    {
      name: 'detail operations of sibling collections are not placed as children',
      input:: function()
        local racks = [c for c in treeOf({ include: ['ListRacks'] }).root.collections if c.name == 'ListRacks'][0];
        {
          [c.segment]: { detail: c.id.detail, children: [s.name for s in c.children.singletons] }
          for c in racks.children.collections
          if c.id != null
        },
      expected: {
        alarms: { detail: 'GetRackAlarm', children: [] },
        sensors: { detail: 'GetRackSensor', children: [] },
      },
    },
    {
      name: 'context inputs are bound to the node context instead of params',
      input:: function()
        local racks = [c for c in treeOf({ include: ['ListRacks'], contextInputs: { RackRegion: 'region' } }).root.collections if c.name == 'ListRacks'][0];
        { params: racks.params, contextInputs: racks.contextInputs },
      expected: { params: [{ name: 'Prefix', type: 'string' }], contextInputs: { RackRegion: 'region' } },
    },
    {
      name: 'list operations with several lists are ambiguous even without pagination',
      input:: function()
        [a for a in treeOf({ include: ['ListRacks'] }).ambiguousItems if a.operation == 'ListRackEvents'],
      expected: [{ operation: 'ListRackEvents', candidates: [['Events'], ['Warnings']] }],
    },
    {
      name: 'list operations of names are collections of the named resource',
      input:: function()
        outline(treeOf({ include: ['ListCrateNames'] }).root),
      expected: {
        crates: { operation: 'ListCrateNames', id: 'CrateName', detail: 'DescribeCrate', children: {} },
      },
    },
    {
      name: 'an optional scalar identifier input of the list operation filters it to the detail',
      input:: function()
        local tanks = [c for c in treeOf({ include: ['DescribeDBTanks'] }).root.collections if c.name == 'DescribeDBTanks'][0];
        { segment: tanks.segment, id: tanks.id },
      expected: {
        segment: 'dbTanks',
        id: {
          param: 'DBTankIdentifier',
          path: ['DBTankIdentifier'],
          input: { DBTankIdentifier: { param: 'DBTankIdentifier' } },
          filter: 'DBTankIdentifier',
          filterValue: { param: 'DBTankIdentifier' },
        },
      },
    },
    {
      name: 'items override wins over the inferred items path',
      input:: function()
        widgets(treeOf({ operations: { DescribeWidgets: { items: ['widgets'] } } })).itemsPath,
      expected: ['widgets'],
    },
    {
      name: 'hidden params are not exposed',
      input:: function()
        widgets(treeOf({ hiddenParams: ['owner'] })).params,
      expected: [],
    },
    {
      name: 'empty explicit columns fall back to the default columns',
      input:: function()
        std.length(widgets(treeOf(columns=[{ operation: 'DescribeWidgets', columns: [] }])).columns),
      expected: 3,
    },
  ],
}
