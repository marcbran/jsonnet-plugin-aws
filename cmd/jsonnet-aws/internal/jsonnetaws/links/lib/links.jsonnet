local linksSources = import 'links-sources.libsonnet';
local treeIndex = import 'tree-index.libsonnet';

local cleanKey(seg) = if seg.const != null then { const: seg.const } else { path: seg.path };

function(model, resources, linksInference)
  local index = treeIndex(model, resources);
  local sources = { [s.operation]: s for s in linksSources.sources(index) };
  local targetPaths = { [c.operation]: c.detailPath for c in index.collections if c.detailPath != null };
  [
    {
      operation: result.operation,
      at: link.at,
      keys: [cleanKey(seg) for seg in link.keys],
      target: {
        operation: link.target,
        params: { [v.param]: v.path for v in link.vars },
      },
    }
    for result in std.sort(linksInference, function(result) result.operation)
    if std.objectHas(sources, result.operation)
    for link in result.links
    if std.objectHas(targetPaths, link.target)
    if !linksSources.isAncestor(targetPaths[link.target], sources[result.operation].path)
  ]
