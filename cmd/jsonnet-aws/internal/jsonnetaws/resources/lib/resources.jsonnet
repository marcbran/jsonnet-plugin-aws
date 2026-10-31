local nest(path, value) =
  if std.length(path) == 0 then value
  else { [path[0]]: nest(path[1:], value) };

local idOverride(id) =
  local param = { param: id.param };
  {
    param: id.param,
    path: id.path,
    input: std.foldl(function(acc, i) std.mergePatch(acc, nest(i.path, param)), id.inputs, {}),
  } + (
    if id.filter == null then {}
    else { filter: id.filter.member, filterValue: [nest(id.filter.itemPath, param)] }
  );

function(model, resources, itemsInference, resourcesInference)
  local results = std.sort(resourcesInference, function(r) r.operation);
  local items = {
    [r.operation]: { items: r.items }
    for r in itemsInference
    if r.decision == 'list'
  };
  local placed = [r for r in results if r.decision == 'place'];
  local collections = std.set([r.collection for r in placed]);
  local inferred = {
    [collection]: { id: idOverride([r for r in placed if r.collection == collection][0].id) }
    for collection in collections
  } + {
    [r.operation]: { skip: true }
    for r in results
    if r.decision == 'skip'
  };
  local existing = std.get(resources, 'operations', {});
  resources {
    operations: std.mergePatch(items, inferred) + existing,
  }
