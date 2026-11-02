local namingLib = import 'naming.libsonnet';

local preludeTypes = {
  'smithy.api#String': 'string',
  'smithy.api#Blob': 'blob',
  'smithy.api#Boolean': 'boolean',
  'smithy.api#PrimitiveBoolean': 'boolean',
  'smithy.api#Byte': 'byte',
  'smithy.api#PrimitiveByte': 'byte',
  'smithy.api#Short': 'short',
  'smithy.api#PrimitiveShort': 'short',
  'smithy.api#Integer': 'integer',
  'smithy.api#PrimitiveInteger': 'integer',
  'smithy.api#Long': 'long',
  'smithy.api#PrimitiveLong': 'long',
  'smithy.api#Float': 'float',
  'smithy.api#PrimitiveFloat': 'float',
  'smithy.api#Double': 'double',
  'smithy.api#PrimitiveDouble': 'double',
  'smithy.api#BigInteger': 'bigInteger',
  'smithy.api#BigDecimal': 'bigDecimal',
  'smithy.api#Timestamp': 'timestamp',
  'smithy.api#Document': 'document',
  'smithy.api#Unit': 'structure',
};

local scalarTypes = ['string', 'enum', 'boolean', 'byte', 'short', 'integer', 'intEnum', 'long', 'float', 'double', 'bigInteger', 'bigDecimal', 'timestamp'];

local verbRank = { Describe: 0, List: 1, Get: 2, Head: 3 };

local localName(id) =
  local parts = std.split(id, '#');
  parts[std.length(parts) - 1];

local traitsOf(x) = std.get(x, 'traits', {});

local hasTrait(x, trait) = std.objectHas(traitsOf(x), trait);

local union(a, b) = std.set(a + b);

local paramType(type) =
  if type == 'boolean' then 'boolean'
  else if std.member(['byte', 'short', 'integer', 'intEnum', 'long', 'float', 'double', 'bigInteger', 'bigDecimal'], type) then 'number'
  else 'string';

local columnRank(name, type, idField) =
  local lower = std.asciiLower(name);
  if name == idField then 0
  else if std.endsWith(lower, 'name') then 1
  else if std.endsWith(lower, 'status') || std.endsWith(lower, 'state') then 2
  else if std.endsWith(lower, 'type') then 3
  else if type == 'timestamp' then 4
  else 5;

local maxColumns = 6;

{
  model:: error 'tree requires a model',
  overrides:: {},
  columns:: [],

  local t = self,
  local shapes = t.model.shapes,
  local operationOverrides = std.get(t.overrides, 'operations', {}),

  local shapeType(id) =
    if std.objectHas(preludeTypes, id) then preludeTypes[id]
    else std.get(std.get(shapes, id, {}), 'type', 'structure'),
  local isScalar(id) = std.member(scalarTypes, shapeType(id)),
  local membersOf(id) = std.get(std.get(shapes, id, {}), 'members', {}),
  local targetOf(ref, fallback) = if ref == null then fallback else ref.target,

  local walkItems(id, path) =
    if std.length(path) == 0 then id
    else if shapeType(id) == 'list' then walkItems(shapes[id].member.target, path)
    else
      local members = membersOf(id);
      if !std.objectHas(members, path[0]) then null
      else walkItems(members[path[0]].target, path[1:]),

  local crossesList(id, path) =
    if std.length(path) <= 1 then false
    else
      local next = std.get(membersOf(id), path[0], null);
      if next == null then false
      else if shapeType(next.target) == 'list' then true
      else crossesList(next.target, path[1:]),

  local itemShape(listId) =
    if listId != null && shapeType(listId) == 'list' then shapes[listId].member.target else null,

  local nounList(outputId, path, noun) =
    if path == null then null
    else
      local item = itemShape(walkItems(outputId, path));
      local nested = if item == null then null else std.get(membersOf(item), noun, null);
      if item != null && shapeType(item) == 'structure' && localName(item) != namingLib.singular(noun) && nested != null && shapeType(nested.target) == 'list' then path + [noun]
      else path,

  local tagsField(fields) =
    local tags = std.get(fields, 'Tags', null);
    local tag = if tags == null || shapeType(tags.target) != 'list' then null else membersOf(shapes[tags.target].member.target);
    tag != null && std.objectHas(tag, 'Key') && std.objectHas(tag, 'Value'),

  local serviceId = [k for k in std.objectFields(shapes) if shapes[k].type == 'service'][0],

  local operation(id) =
    local name = localName(id);
    local shape = shapes[id];
    local inputId = targetOf(std.get(shape, 'input', null), 'smithy.api#Unit');
    local outputId = targetOf(std.get(shape, 'output', null), 'smithy.api#Unit');
    local paginated = std.get(traitsOf(shape), 'smithy.api#paginated', null);
    local inputs = membersOf(inputId);
    local outputs = membersOf(outputId);
    local pagingInputs = if paginated == null then [] else [
      m
      for m in [std.get(paginated, 'inputToken', null), std.get(paginated, 'pageSize', null)]
      if m != null
    ];
    local pagingOutputs = if paginated == null then [] else [
      m
      for m in [std.get(paginated, 'outputToken', null)]
      if m != null
    ];
    local listOutputs = [
      m
      for m in std.objectFields(outputs)
      if shapeType(outputs[m].target) == 'list' && !std.member(pagingOutputs, m)
    ];
    local override = std.get(operationOverrides, name, {});
    local nestedLists = [
      path
      for m in std.objectFields(outputs)
      if !std.member(pagingOutputs, m)
      for path in (
        if shapeType(outputs[m].target) == 'list' then [[m]]
        else if shapeType(outputs[m].target) == 'structure' then [
          [m, n]
          for n in std.objectFields(membersOf(outputs[m].target))
          if shapeType(membersOf(outputs[m].target)[n].target) == 'list'
        ]
        else []
      )
    ];
    local itemsPath =
      if std.objectHas(override, 'items') then override.items
      else if paginated != null && std.objectHas(paginated, 'items') then std.split(paginated.items, '.')
      else if paginated != null && std.length(nestedLists) == 1 then nestedLists[0]
      else if std.length(listOutputs) == 1 && std.member(['List', 'Describe'], namingLib.verb(name)) then listOutputs
      else null;
    local resolvedItems = if std.objectHas(override, 'items') then itemsPath else nounList(outputId, itemsPath, namingLib.noun(name));
    local listId = if resolvedItems == null then null else walkItems(outputId, resolvedItems);
    local itemId = itemShape(listId);
    {
      name: name,
      outputId: outputId,
      verb: namingLib.verb(name),
      noun: namingLib.noun(name),
      inputs: inputs,
      required: std.set([m for m in std.objectFields(inputs) if hasTrait(inputs[m], 'smithy.api#required')]),
      optional: std.set([
        m
        for m in std.objectFields(inputs)
        if !hasTrait(inputs[m], 'smithy.api#required') && !std.member(pagingInputs, m)
      ]),
      paginated: if paginated == null then null else {
        inputToken: std.get(paginated, 'inputToken', null),
        outputToken: std.get(paginated, 'outputToken', null),
        pageSize: std.get(paginated, 'pageSize', null),
      },
      itemsPath: if itemId == null then null else resolvedItems,
      itemsFlatten: itemId != null && crossesList(outputId, resolvedItems),
      ambiguousItems: if itemsPath == null && ((paginated != null && !std.objectHas(paginated, 'items')) || std.member(['List', 'Describe'], namingLib.verb(name))) && std.length(nestedLists) > 1 then nestedLists else null,
      itemId: itemId,
      collection: itemId != null,
      documentation: std.get(traitsOf(shape), 'smithy.api#documentation', null),
      override: override,
    },

  local candidates = [
    op
    for ref in shapes[serviceId].operations
    for op in [operation(ref.target)]
    if op.verb != null && op.verb != 'BatchGet' && !std.get(op.override, 'skip', false)
  ],

  local signature(op) = op.noun + '|' + std.join(',', op.required),
  local preferred(group) = std.sort(group, function(op) '%d|%03d' % [std.get(verbRank, op.verb, 9), 999 - std.length(op.name)])[0],
  local operations = [
    preferred([op for op in candidates if signature(op) == s])
    for s in std.set([signature(op) for op in candidates])
  ],

  local hiddenParams = std.get(t.overrides, 'hiddenParams', []),

  local contextInputs = std.get(t.overrides, 'contextInputs', {}),

  local contextInputsOf(op) = {
    [m]: contextInputs[m]
    for m in std.objectFields(op.inputs)
    if std.objectHas(contextInputs, m)
  },

  local scalarParams(op) = [
    { name: m, type: paramType(shapeType(op.inputs[m].target)) }
    for m in op.optional
    if isScalar(op.inputs[m].target) && !std.member(hiddenParams, m) && !std.objectHas(contextInputs, m)
  ],

  local defaultColumns(c, id) =
    if c.itemId != null && isScalar(c.itemId) then [{ label: namingLib.label(namingLib.singular(c.noun)), path: [] }]
    else
      local fields = itemFields(c);
      local idField = if id == null || std.length(id.path) == 0 then null else id.path[0];
      local scalars = [
        { name: f, rank: columnRank(f, shapeType(fields[f].target), idField) }
        for f in std.objectFields(fields)
        if isScalar(fields[f].target)
      ];
      local ranked = std.sort(scalars, function(f) '%d|%s' % [f.rank, f.name]);
      [{ label: namingLib.label(f.name), path: [f.name] } for f in ranked[:std.min(maxColumns, std.length(ranked))]],

  local nameColumn = { label: 'Name', tag: 'Name' },

  local columnsFor(c, id) =
    local explicit = [entry.columns for entry in t.columns if entry.operation == c.name && std.length(entry.columns) > 0];
    local columns = if std.length(explicit) > 0 then explicit[0] else defaultColumns(c, id);
    local hasTag = std.length([col for col in columns if std.objectHas(col, 'tag')]) > 0;
    if tagsField(itemFields(c)) && !hasTag then [nameColumn] + columns else columns,

  local itemFields(c) = if c.itemId == null || isScalar(c.itemId) then {} else membersOf(c.itemId),

  local identity(c, scope) =
    local single = namingLib.singular(c.noun);
    local fields = itemFields(c);
    local fallbackNames = [
      namingLib.lowerFirst(single) + 'Name',
      namingLib.lowerFirst(single) + 'Id',
      single + 'Name',
      single + 'Id',
      'name',
      'id',
      'Name',
      'Id',
    ];
    local fallbacks = [n for n in fallbackNames if std.objectHas(fields, n) && isScalar(fields[n].target)];
    local detailOps = [
      op
      for op in operations
      if !op.collection && op.noun == single
      for extra in [std.setDiff(op.required, scope)]
      if std.length(extra) == 1 && std.setUnion(scope, extra) == op.required
    ];
    local fromDetail =
      if std.length(detailOps) == 0 then null
      else
        local op = detailOps[0];
        local param = std.setDiff(op.required, scope)[0];
        local path =
          if c.itemId != null && isScalar(c.itemId) then []
          else if std.objectHas(fields, param) then [param]
          else if param == single && std.length(fallbacks) > 0 then [fallbacks[0]]
          else null;
        if path == null then null
        else { param: param, path: path, input: { [param]: { param: param } }, detail: op.name };
    local filters = [
      { member: m, field: namingLib.singular(m) }
      for m in c.optional
      if shapeType(c.inputs[m].target) == 'list' && std.objectHas(fields, namingLib.singular(m)) && isScalar(fields[namingLib.singular(m)].target)
    ];
    local fromFilter =
      if std.length(filters) == 0 then null
      else
        local f = filters[0];
        { param: f.field, path: [f.field], input: { [f.field]: { param: f.field } }, filter: f.member };
    local nounInput = [op for op in operations if op.required == std.setUnion(scope, [single])];
    local fromFallback =
      if std.length(fallbacks) == 0 then null
      else if std.length(nounInput) > 0 && !std.objectHas(fields, single) then
        { param: single, path: [fallbacks[0]], input: { [single]: { param: single } } }
      else { param: fallbacks[0], path: [fallbacks[0]], input: { [fallbacks[0]]: { param: fallbacks[0] } } };
    local override = std.get(c.override, 'id', null);
    if override != null then override
    else if fromDetail != null then fromDetail
    else if fromFilter != null then fromFilter
    else fromFallback,

  local segment(op, parentSingular) =
    std.get(op.override, 'name', namingLib.lowerFirst(namingLib.stripPrefix(op.noun, parentSingular))),

  local place(scope, parentSingular, exclude, depth) =
    local here = [op for op in operations if op.required == scope && !std.member(exclude, op.name)];
    local details = [
      id.detail
      for c in here
      if c.collection
      for id in [identity(c, scope)]
      if id != null && std.objectHas(id, 'detail')
    ];
    {
      collections: [
        local id = identity(c, scope);
        local childScope = if id == null then scope else union(scope, std.objectFields(id.input));
        c {
          segment: segment(c, parentSingular),
          id: id,
          children:
            if id == null || childScope == scope || depth > 8 then null
            else place(childScope, namingLib.singular(c.noun), exclude + details, depth + 1),
          params: scalarParams(c),
          contextInputs: contextInputsOf(c),
          columns: columnsFor(c, id),
        }
        for c in here
        if c.collection
      ],
      singletons: [
        s {
          segment: segment(s, parentSingular),
          params: scalarParams(s),
          contextInputs: contextInputsOf(s),
        }
        for s in here
        if !s.collection
      ],
    },

  local placedNames(node) =
    if node == null then []
    else
      [s.name for s in node.singletons] +
      std.flattenArrays([
        [c.name] + (if c.id != null && std.objectHas(c.id, 'detail') then [c.id.detail] else []) + placedNames(c.children)
        for c in node.collections
      ]),

  local include = std.get(t.overrides, 'include', null),

  local fullRoot = place([], null, [], 0),

  local root =
    if include == null then fullRoot
    else fullRoot {
      collections: [c for c in fullRoot.collections if std.member(include, c.name)],
      singletons: [s for s in fullRoot.singletons if std.member(include, s.name)],
    },

  local kept = std.set(placedNames(root)),

  local relevant(name) = include == null || std.member(kept, name) || std.member(include, name),

  service: {
    id: serviceId,
    name: localName(serviceId),
    sdkId: std.get(std.get(traitsOf(shapes[serviceId]), 'aws.api#service', {}), 'sdkId', localName(serviceId)),
  },
  root: root,
  unplaced: std.setDiff(std.set([op.name for op in operations if include == null || std.member(include, op.name)]), std.set(placedNames(fullRoot))),
  allOperations:: operations,
  ambiguousItems:: [
    { operation: op.name, candidates: op.ambiguousItems }
    for op in operations
    if op.ambiguousItems != null && relevant(op.name)
  ],
  superseded: std.setDiff(std.set([op.name for op in candidates]), std.set([op.name for op in operations])),
}
