local walk(value, path) =
  if std.length(path) == 0 || value == null then value
  else if std.type(value) != 'object' then null
  else walk(std.get(value, path[0], null), path[1:]);

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
    local items = walk($.response, $.itemsPath);
    if std.type(items) == 'array' && std.length(items) > 0 then items[0] else $.response,
};

{
  regional: regional,
  paginated: paginated,
  single: single,
}
