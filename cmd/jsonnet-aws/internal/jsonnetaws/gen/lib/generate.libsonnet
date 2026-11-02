local jsonnetMainLib = import 'jsonnet/main.libsonnet';

local j = jsonnetMainLib;

local le(indent) = j.Fodder.LineEnd(0, indent);

local prettyArray(elements, indent) =
  j.Array([
    element.fodder(le(indent + 2))
    for element in elements
  ]).closeFodder(le(indent));

local prettyObject(fields, indent) =
  j.Object([
    field { fodder: [le(indent + 2)] }
    for field in fields
  ]).closeFodder(le(indent));

local prettyApply(target, args, indent) =
  j.Apply(target, [
    arg.fodder(le(indent + 2))
    for arg in args
  ]).rightFodder(le(indent));

local isAsciiLetter(c) = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');

local isAsciiDigit(c) = c >= '0' && c <= '9';

local jsonnetKeywords = ['assert', 'else', 'error', 'false', 'for', 'function', 'if', 'import', 'importstr', 'in', 'local', 'null', 'self', 'super', 'tailstrict', 'then', 'true'];

local isUnquotedFieldName(s) =
  std.length(s) > 0 &&
  (s[0] == '_' || isAsciiLetter(s[0])) &&
  std.all([c == '_' || isAsciiLetter(c) || isAsciiDigit(c) for c in std.stringChars(s)]) &&
  !std.member(jsonnetKeywords, s);

local objectField(name, expr) =
  if isUnquotedFieldName(name) then j.Field(name, expr) else j.Field(j.String(name), expr);

local hiddenField(name, expr) = objectField(name, expr) { Hide: 0 };

local access(expr, name) =
  if isUnquotedFieldName(name) then j.Member(expr, name) else j.Index(expr, j.String(name));

local literal(value) =
  if value == null then j.Null
  else if std.type(value) == 'string' then j.String(value)
  else if std.type(value) == 'boolean' then if value then j.True else j.False
  else if std.type(value) == 'number' then j.Number(std.toString(value))
  else if std.type(value) == 'array' then j.Array([literal(item) for item in value])
  else if std.type(value) == 'object' then j.Object([objectField(f, literal(value[f])) for f in std.objectFields(value)])
  else error 'unsupported literal type: ' + std.type(value);

local isParamRef(value) = std.type(value) == 'object' && std.objectFields(value) == ['param'];

local template(value, indent) =
  if isParamRef(value) then access(j.Dollar, value.param)
  else if std.type(value) == 'object' then
    prettyObject([objectField(f, template(value[f], indent + 2)) for f in std.objectFields(value)], indent)
  else if std.type(value) == 'array' then j.Array([template(item, indent) for item in value])
  else literal(value);

local view(name) = j.Member(j.Member(j.Var('a'), name), 'node');

local mixin(name) = j.Member(j.Var('aws'), name);

local adds(exprs) = std.foldl(function(acc, e) j.Add(acc, e), exprs[1:], exprs[0]);

local selfMember(name) = j.Member(j.Self, name);

local paramValue(name) =
  j.Std.get(access(j.Dollar, '_params'), j.String(name)).default(j.Null);

{
  service:: error 'generate requires a service',
  tree:: error 'generate requires a tree',
  links:: [],
  manifest:: true,
  base:: ['aws', '$account', '$region'],
  baseLinks:: [{ const: 'aws' }, { origin: 'account' }, { origin: 'region' }],

  local g = self,

  local fromContext(op) = {
    [k]: { param: std.get(op, 'contextInputs', {})[k] }
    for k in std.objectFields(std.get(op, 'contextInputs', {}))
  },

  local hasPages(c) =
    c.id != null && (
      std.objectHas(c.id, 'detail') ||
      std.objectHas(c.id, 'filter') ||
      (c.children != null && std.length(c.children.collections) + std.length(c.children.singletons) > 0)
    ),

  local targets(node, segments) =
    std.flattenArrays([
      local cSegments = segments + [c.segment];
      if !hasPages(c) then []
      else
        local idSegments = cSegments + ['$' + c.id.param];
        [{ operation: c.name, segments: idSegments }] +
        (if c.children == null then [] else targets(c.children, idSegments))
      for c in node.collections
    ]),

  local targetIndex = {
    [t.operation]: t.segments
    for t in targets(g.tree.root, [])
  },

  local linkValue(link) =
    local segments = std.get(targetIndex, link.target.operation, null);
    if segments == null then null
    else
      local value = [
        if std.startsWith(seg, '$') then
          local param = seg[1:];
          if std.objectHas(link.target.params, param) then { param: param, path: link.target.params[param] } else null
        else { const: seg }
        for seg in segments
      ];
      if std.member(value, null) then null
      else g.baseLinks + [{ const: g.service }] + value,

  local inferredLinks(operation, prefix) = [
    { at: link.at[std.length(prefix):], keys: link.keys, value: value }
    for link in g.links
    if link.operation == operation
    if std.length(link.at) >= std.length(prefix) && link.at[:std.length(prefix)] == prefix
    for value in [linkValue(link)]
    if value != null
  ],

  local linkSpecsField(specs) =
    if std.length(specs) == 0 then []
    else [
      hiddenField('linkSpecs', prettyArray([
        prettyObject([
          objectField('at', literal(spec.at)),
          objectField('keys', literal(spec.keys)),
          objectField('value', literal(spec.value)),
        ], 4)
        for spec in specs
      ], 2)),
    ],

  local inputExpr(scope, params, extra, paginated) =
    local fields =
      [objectField(f, template(scope[f], 6)) for f in std.objectFields(scope)] +
      [objectField(f, template(extra[f], 6)) for f in std.objectFields(extra)] +
      [objectField(p.name, paramValue(p.name)) for p in params];
    local obj = if std.length(fields) == 0 then j.Object([]) else prettyObject(fields, 4);
    if paginated then
      if std.length(fields) == 0 then selfMember('page') else j.Add(selfMember('page'), obj)
    else obj,

  local callExpr(operation, input) =
    prettyApply(j.Var('call'), [selfMember('ctx'), j.String(operation), input], 4),

  local paramSpecsFields(params) =
    if std.length(params) == 0 then []
    else [
      objectField('_paramSpecs', prettyArray([
        literal({ name: p.name, type: p.type, default: null })
        for p in params
      ], 4)) { SuperSugar: true },
    ],

  local pathExpr(path) = j.Array([j.String(p) for p in path]),

  local entry(path, node) =
    if node == null then j.Array([pathExpr(path)])
    else j.Array([pathExpr(path), node]),

  local columnExpr(col) =
    if std.objectHas(col, 'tag') then
      j.Object([
        objectField('label', literal(col.label)),
        hiddenField('value', j.Apply(mixin('tag'), [j.String(col.tag)])),
      ])
    else literal(col),

  local collectionNode(c, scope, links) =
    local paginated = c.paginated != null;
    local flatten = std.get(c, 'itemsFlatten', false);
    local at = if flatten then ['items'] else c.itemsPath;
    local bases = [view('table'), mixin('regional')] + (if paginated then [mixin('paginated')] else []) + (if flatten then [mixin('flattened')] else []);
    local pagination =
      if !paginated then []
      else [
        hiddenField(k, literal(c.paginated[k]))
        for k in ['inputToken', 'outputToken', 'pageSize']
        if c.paginated[k] != null
      ];
    local rowLink =
      if !hasPages(c) then []
      else [{ at: at, keys: [{ path: c.id.path }], value: links + [{ param: c.id.param, path: c.id.path }] }];
    local itemLinks =
      if flatten then [l { at: ['items'] + l.at } for l in inferredLinks(c.name, c.itemsPath)]
      else inferredLinks(c.name, []);
    local linkSpecs = linkSpecsField(rowLink + itemLinks);
    adds(bases + [prettyObject(
      pagination +
      [
        hiddenField('response', callExpr(c.name, inputExpr(scope, c.params, fromContext(c), paginated))),
      ] +
      (if flatten then [hiddenField('itemsPath', literal(c.itemsPath))] else [hiddenField('data', selfMember('response'))]) +
      [
        hiddenField('table', prettyObject([
          objectField('at', literal(at)),
          objectField('columns', prettyArray([columnExpr(col) for col in c.columns], 4)),
        ], 2)),
      ] +
      linkSpecs +
      paramSpecsFields(c.params),
      0
    )]),

  local detailNode(c, scope) =
    local id = c.id;
    local idInput = std.mergePatch(scope, id.input);
    if std.objectHas(id, 'detail') then
      adds([view('resource'), mixin('regional'), prettyObject([
        objectField('data', callExpr(id.detail, inputExpr(idInput, [], {}, false))),
      ] + linkSpecsField(inferredLinks(id.detail, [])), 0)])
    else if std.objectHas(id, 'filter') then
      adds([view('resource'), mixin('regional'), mixin('single'), prettyObject([
        hiddenField('itemsPath', literal(c.itemsPath)),
        hiddenField('response', callExpr(c.name, inputExpr(scope, [], fromContext(c) { [id.filter]: std.get(id, 'filterValue', [{ param: id.param }]) }, false))),
      ] + linkSpecsField(inferredLinks(c.name, c.itemsPath)), 0)])
    else null,

  local singletonNode(s, scope) =
    adds([view('resource'), mixin('regional'), prettyObject(
      [objectField('data', callExpr(s.name, inputExpr(scope, s.params, fromContext(s), false)))] +
      linkSpecsField(inferredLinks(s.name, [])) +
      paramSpecsFields(s.params),
      0
    )]),

  local entries(node, path, links, scope) =
    std.flattenArrays([
      local cPath = path + [c.segment];
      local cLinks = links + [{ const: c.segment }];
      [entry(cPath, collectionNode(c, scope, cLinks))] +
      (
        if !hasPages(c) then []
        else
          local idPath = cPath + ['$' + c.id.param];
          [entry(idPath, detailNode(c, scope))] +
          (if c.children == null then [] else entries(c.children, idPath, cLinks + [{ origin: c.id.param }], std.mergePatch(scope, c.id.input)))
      )
      for c in node.collections
    ]) + [
      entry(path + [s.segment], singletonNode(s, scope))
      for s in node.singletons
    ],

  local servicePath = g.base + [g.service],

  local rootExpr(path) =
    std.foldl(
      function(acc, seg)
        if std.startsWith(seg, '$') then j.Apply(access(acc, seg[1:]), [access(j.Dollar, seg[1:])])
        else access(acc, seg),
      path,
      j.Var('root')
    ),

  local serviceLink =
    entry(g.base, prettyObject([
      objectField('links', prettyObject([
        objectField(g.tree.service.sdkId, rootExpr(servicePath)),
      ], 2)) { SuperSugar: true },
    ], 0)),

  local body = prettyArray(
    [serviceLink, entry(servicePath, null)] +
    entries(g.tree.root, servicePath, g.baseLinks + [{ const: g.service }], {}),
    0
  ),

  local generated = j.Local([
    j.LocalBind('a', j.Import('arcourse-ui/main.libsonnet')),
    j.LocalBind('aws', j.Import('mixins.libsonnet')).varFodder(le(0)),
    j.LocalBind('root', j.Import('root')).varFodder(le(0)),
    j.LocalFunctionBind(
      'call',
      [j.Parameter('ctx'), j.Parameter('operation'), j.Parameter('input')],
      j.Apply(j.Apply(j.Member(j.Var('std'), 'native'), [j.String('invoke:aws')]), [
        j.String('call'),
        j.Array([j.Var('ctx'), j.String(g.service), j.Var('operation'), j.Var('input')]),
      ])
    ).varFodder(le(0)),
  ], body.fodder(j.Fodder.LineEnd(1, 0))),

  jsonnet: if g.manifest then j.manifestJsonnet(generated) else generated,
}
