local treeLib = import 'tree.libsonnet';

local display(segments) = std.join('/', segments);

local hasPages(c) =
  c.id != null && (
    std.objectHas(c.id, 'detail') ||
    std.objectHas(c.id, 'filter') ||
    (c.children != null && std.length(c.children.collections) + std.length(c.children.singletons) > 0)
  );

local collect(node, segments, params) =
  std.flattenArrays([
    local cSegments = segments + [c.segment];
    local cParams = params + (if c.id == null then [] else [c.id.param]);
    [
      {
        operation: c.name,
        path: display(cSegments),
        detailPath: if !hasPages(c) then null else display(cSegments + ['{' + c.id.param + '}']),
        params: cParams,
        id: c.id,
        itemsPath: c.itemsPath,
        itemId: c.itemId,
        outputId: c.outputId,
        required: c.required,
        detail: if c.id == null then null else std.get(c.id, 'detail', null),
        documentation: c.documentation,
      },
    ] + (if c.children == null then [] else collect(c.children, cSegments + ['{' + c.id.param + '}'], cParams))
    for c in node.collections
  ]);

local collectSingletons(node, segments) =
  [
    { operation: s.name, path: display(segments + [s.segment]), outputId: s.outputId, required: s.required, documentation: s.documentation }
    for s in node.singletons
  ] + std.flattenArrays([
    collectSingletons(c.children, segments + [c.segment, '{' + c.id.param + '}'])
    for c in node.collections
    if c.children != null
  ]);

function(model, resources, columns=[])
  local tree = treeLib {
    model:: model,
    overrides:: resources,
    columns:: columns,
  };
  {
    tree: tree,
    collections: collect(tree.root, [], []),
    singletons: collectSingletons(tree.root, []),
    unplaced: tree.unplaced,
    operations: {
      [op.name]: op
      for op in tree.allOperations
    },
  }
