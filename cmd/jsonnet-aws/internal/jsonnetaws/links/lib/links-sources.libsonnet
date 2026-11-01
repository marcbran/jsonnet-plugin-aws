local shapes = import 'shapes.libsonnet';

local segments(path) = std.split(path, '/');

{
  isAncestor(target, path)::
    local t = segments(target);
    local p = segments(path);
    std.length(t) <= std.length(p) && p[:std.length(t)] == t,

  sources(index):: [
    { operation: c.operation, path: c.path, outputId: c.outputId, at: c.itemsPath, own: c.operation }
    for c in index.collections
  ] + [
    { operation: c.detail, path: c.detailPath, outputId: index.operations[c.detail].outputId, at: null, own: c.operation }
    for c in index.collections
    if c.detail != null
  ] + [
    { operation: s.operation, path: s.path, outputId: s.outputId, at: null, own: null }
    for s in index.singletons
  ],

  targets(index, source):: [
    { operation: c.operation, path: c.detailPath, params: c.params }
    for c in index.collections
    if c.detailPath != null && (c.operation == source.own || !self.isAncestor(c.detailPath, source.path))
  ],

  isSelfLink(index, source, link)::
    local own = [c for c in index.collections if c.operation == source.own];
    if std.length(own) == 0 || link.target.operation != source.own then false
    else
      local id = own[0].id;
      local itemAt = if source.at == null then [] else source.at;
      link.at == itemAt && std.get(link.target.params, id.param, null) == id.path,
}
