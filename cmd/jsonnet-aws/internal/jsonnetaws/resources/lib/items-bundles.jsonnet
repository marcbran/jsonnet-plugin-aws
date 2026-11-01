local shapes = import 'shapes.libsonnet';
local treeIndex = import 'tree-index.libsonnet';

function(model, resources)
  local index = treeIndex(model, resources);
  {
    [entry.operation]: {
      'input.json': std.manifestJsonEx({
        operation: entry.operation,
        documentation: index.operations[entry.operation].documentation,
        outputSchema: shapes.schema(model, index.operations[entry.operation].outputId, 4),
        listCandidates: entry.candidates,
      }, '  '),
    }
    for entry in index.tree.ambiguousItems
  }
