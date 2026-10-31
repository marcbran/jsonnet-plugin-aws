local linksSources = import 'links-sources.libsonnet';
local shapes = import 'shapes.libsonnet';
local treeIndex = import 'tree-index.libsonnet';

function(model, resources)
  local index = treeIndex(model, resources);
  {
    [source.operation]: {
      'input.json': std.manifestJsonEx({
        operation: source.operation,
        path: source.path,
        at: source.at,
        responseSchema: shapes.schema(model, source.outputId),
        targets: linksSources.targets(index, source),
      }, '  '),
    }
    for source in linksSources.sources(index)
  }
