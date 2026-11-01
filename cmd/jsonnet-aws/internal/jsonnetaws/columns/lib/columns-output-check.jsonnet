local shapes = import 'shapes.libsonnet';

local keyFor(column) = std.get(column, 'key', std.join('.', column.path));

local columnProblems(itemSchema, column) =
  local path = std.manifestJsonMinified(column.path);
  if std.length(column.path) == 0 then
    if shapes.isScalar(itemSchema) then []
    else [std.format('column path %s is only valid when the list items are scalar values', [path])]
  else
    local info = shapes.at(itemSchema, column.path);
    if info.schema == null then [std.format('column path %s does not exist in itemSchema', [path])]
    else if info.crossedArray then [std.format('column path %s crosses an array; a column must resolve to a single value per list item', [path])]
    else [];

function(input, output)
  local checked = [
    { column: column, problems: columnProblems(input.itemSchema, column) }
    for column in output.columns
  ];
  local valid = [entry.column for entry in checked if std.length(entry.problems) == 0];
  local keys = [keyFor(column) for column in valid];
  local duplicates = std.set([key for key in keys if std.count(keys, key) > 1]);
  local unique = [
    column
    for i in std.range(0, std.length(valid) - 1)
    for column in [valid[i]]
    if std.count(keys[0:i], keyFor(column)) == 0
  ];
  local primaries = std.length([column for column in unique if column.priority == 'primary']);
  {
    valid: output {
      operation: input.operation,
      array: input.array,
      columns: unique,
    },
    problems: std.flattenArrays([entry.problems for entry in checked]) + [
      std.format('column key %s is used more than once; keys must be unique', [key])
      for key in duplicates
    ] + [
      std.format('exactly one column must have priority "primary", found %d', [primaries])
      for _ in [null]
      if primaries != 1
    ],
  }
