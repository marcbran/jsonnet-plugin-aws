local collect(value, path) =
  if value == null then []
  else if std.type(value) == 'array' then std.flatMap(function(v) collect(v, path), value)
  else if std.length(path) == 0 then [value]
  else if std.type(value) != 'object' then []
  else collect(std.get(value, path[0], null), path[1:]);

local regional = {
  ctx:: { account: $.account, region: $.region },
};

local paginated = {
  inputToken:: 'nextToken',
  outputToken:: 'nextToken',
  pageSize:: null,
  _paramSpecs+: [
    { name: name, type: if name == $.pageSize then 'number' else 'string', default: null }
    for name in [$.pageSize, $.inputToken]
    if name != null
  ],
  page:: {
    [name]: std.get($._params, name, null)
    for name in [$.pageSize, $.inputToken]
    if name != null
  },
  links+: {
    pagination:
      local params = std.get($, '_params', {});
      local next = std.get($.response, $.outputToken, null);
      (if std.get(params, $.inputToken, null) == null then {} else { first: $ { _params: params { [$.inputToken]: null } } })
      + (if next == null then {} else { next: $ { _params: params { [$.inputToken]: next } } }),
  },
};

local single = {
  itemsPath:: [],
  response:: error 'single requires a response',
  data:
    local items = collect(std.get($.response, $.itemsPath[0], null), $.itemsPath[1:]);
    if std.objectHas($.response, $.itemsPath[0]) && std.length(items) > 0 then items[0] else $.response,
};

local flattened = {
  itemsPath:: error 'flattened requires an itemsPath',
  response:: error 'flattened requires a response',
  data:: { items: collect(std.get($.response, $.itemsPath[0], null), $.itemsPath[1:]) },
};

local tag(key) = function(item)
  local matches = [t.Value for t in std.get(item, 'Tags', []) if std.get(t, 'Key', null) == key];
  if std.length(matches) == 0 then null else matches[0];

{
  regional: regional,
  paginated: paginated,
  single: single,
  flattened: flattened,
  tag: tag,
}
