local shapes = import 'shapes.libsonnet';
local treeIndex = import 'tree-index.libsonnet';

function(model, resources)
  local index = treeIndex(model, resources);
  {
    [c.operation]: {
      'input.json': std.manifestJsonEx({
        operation: c.operation,
        path: c.path,
        array: c.itemsPath,
        itemSchema: shapes.schema(model, c.itemId, 3),
      }, '  '),
    }
    for c in index.collections
  }
