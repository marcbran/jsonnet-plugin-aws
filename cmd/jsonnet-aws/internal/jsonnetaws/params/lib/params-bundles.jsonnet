local treeIndex = import 'tree-index.libsonnet';

local afterTag(part) =
  local close = std.findSubstr('>', part);
  if std.length(close) == 0 then '' else std.substr(part, close[0] + 1, std.length(part) - close[0] - 1);

local stripTags(text) =
  local parts = std.split(text, '<');
  parts[0] + std.join('', [afterTag(part) for part in parts[1:]]);

local summary(text) =
  local plain = std.stripChars(std.join(' ', [word for word in std.split(stripTags(text), ' ') if word != '']), ' \n');
  if std.length(plain) <= 400 then plain else std.substr(plain, 0, 400) + '…';

local paramEntry(param) = {
  name: param.name,
  type: param.type,
} + {
  [field]: param[field]
  for field in ['items', 'enum']
  if std.objectHas(param, field)
} + (
  if std.objectHas(param, 'documentation') then { documentation: summary(param.documentation) } else {}
);

function(model, resources)
  local index = treeIndex(model, resources);
  {
    [c.operation]: {
      'input.json': std.manifestJsonEx({
        operation: c.operation,
        path: c.path,
        params: [paramEntry(param) for param in c.queryParams],
      }, '  '),
    }
    for c in index.collections
    if std.length(c.queryParams) > 0
  }
