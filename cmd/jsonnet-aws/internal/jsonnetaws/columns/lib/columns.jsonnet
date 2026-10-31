local keyFor(path) = std.join('.', path);

function(model, resources, columnsInference)
  [
    {
      operation: item.operation,
      array: item.array,
      columns: [
        {
          key: std.get(column, 'key', keyFor(column.path)),
          path: column.path,
          label: column.label,
          kind: column.kind,
          priority: column.priority,
        }
        for column in item.columns
      ],
    }
    for item in std.sort(columnsInference, function(item) item.operation)
  ]
