local shapes = import 'shapes.libsonnet';
local treeIndex = import 'tree-index.libsonnet';

local listInputs(model, op) = [
  m
  for m in std.objectFields(op.inputs)
  if shapes.schema(model, op.inputs[m].target, 1).type == 'array'
];

function(model, resources)
  local index = treeIndex(model, resources);
  {
    [name]: {
      'input.json': std.manifestJsonEx({
        operation: name,
        documentation: op.documentation,
        required: {
          [m]: shapes.schema(model, op.inputs[m].target, 3)
          for m in op.required
        },
        candidates: [
          {
            operation: c.operation,
            path: c.path,
            provides: c.required,
            listInputs: listInputs(model, index.operations[c.operation]),
            itemSchema: if c.itemId == null then null else shapes.schema(model, c.itemId, 3),
          }
          for c in index.collections
          if c.id == null
        ],
      }, '  '),
    }
    for name in index.unplaced
    for op in [index.operations[name]]
  }
