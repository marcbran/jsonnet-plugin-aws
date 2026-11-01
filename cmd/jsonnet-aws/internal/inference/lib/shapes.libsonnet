local preludeTypes = {
  'smithy.api#String': 'string',
  'smithy.api#Blob': 'blob',
  'smithy.api#Boolean': 'boolean',
  'smithy.api#PrimitiveBoolean': 'boolean',
  'smithy.api#Integer': 'integer',
  'smithy.api#PrimitiveInteger': 'integer',
  'smithy.api#Long': 'long',
  'smithy.api#PrimitiveLong': 'long',
  'smithy.api#Float': 'float',
  'smithy.api#Double': 'double',
  'smithy.api#Timestamp': 'timestamp',
  'smithy.api#Document': 'document',
  'smithy.api#Unit': 'structure',
};

local maxDepth = 5;

local shapeType(model, id) =
  if std.objectHas(preludeTypes, id) then preludeTypes[id]
  else std.get(std.get(model.shapes, id, {}), 'type', 'structure');

local schema(model, id, depth=maxDepth) =
  local type = shapeType(model, id);
  local shape = std.get(model.shapes, id, {});
  if type == 'structure' || type == 'union' then
    if depth <= 0 then { type: 'object' }
    else {
      type: 'object',
      properties: {
        [m]: schema(model, shape.members[m].target, depth - 1)
        for m in std.objectFields(std.get(shape, 'members', {}))
      },
    }
  else if type == 'list' || type == 'set' then { type: 'array', items: schema(model, shape.member.target, depth) }
  else if type == 'map' then { type: 'object', additionalProperties: schema(model, shape.value.target, depth - 1) }
  else if type == 'enum' then { type: 'string', enum: std.objectFields(std.get(shape, 'members', {})) }
  else { type: type };

local isScalar(s) = std.member(['string', 'boolean', 'integer', 'long', 'float', 'double', 'timestamp', 'byte', 'short', 'intEnum', 'bigInteger', 'bigDecimal', 'blob'], s.type);

local walk(s, path, crossed=false) =
  if s == null then { schema: null, crossedArray: crossed }
  else if s.type == 'array' then walk(s.items, path, true)
  else if std.length(path) == 0 then { schema: s, crossedArray: crossed }
  else
    local next = std.get(std.get(s, 'properties', {}), path[0], null);
    walk(next, path[1:], crossed);

local at(s, path) =
  if std.length(path) == 0 then { schema: s, crossedArray: false }
  else
    local next = std.get(std.get(s, 'properties', {}), path[0], null);
    if next == null then { schema: null, crossedArray: false }
    else if next.type == 'array' then
      local rest = at(next.items, path[1:]);
      rest { crossedArray: true }
    else at(next, path[1:]);

{
  schema:: schema,
  isScalar:: isScalar,
  at:: at,
  walk:: walk,
}
