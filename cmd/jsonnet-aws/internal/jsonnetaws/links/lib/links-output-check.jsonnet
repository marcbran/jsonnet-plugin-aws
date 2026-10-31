local shapes = import 'shapes.libsonnet';

local linkProblems(input, link) =
  local anchor = shapes.at(input.responseSchema, link.at);
  local matches = [t for t in input.targets if t.operation == link.target];
  local label = std.format('link at %s to %s', [std.manifestJsonMinified(link.at), link.target]);
  if anchor.schema == null then [std.format('%s: "at" does not exist in responseSchema', [label])]
  else if std.length(matches) == 0 then [std.format('%s: target is not one of the targets', [label])]
  else
    local target = matches[0];
    local params = std.set([v.param for v in link.vars]);
    local relative(path) = shapes.at(anchor.schema, path);
    [
      std.format('%s: key path %s does not resolve to a single value at "at"', [label, std.manifestJsonMinified(seg.path)])
      for seg in link.keys
      if seg.path != null
      for info in [if std.length(seg.path) == 0 then { schema: anchor.schema, crossedArray: false } else relative(seg.path)]
      if info.schema == null || info.crossedArray || !shapes.isScalar(info.schema)
    ] + [
      std.format('%s: vars must provide exactly the target params %s', [label, std.manifestJsonMinified(target.params)])
      for _ in [null]
      if params != std.set(target.params)
    ] + [
      std.format('%s: var path %s for %s does not resolve to a single scalar value at "at"', [label, std.manifestJsonMinified(v.path), v.param])
      for v in link.vars
      for info in [if std.length(v.path) == 0 then { schema: anchor.schema, crossedArray: false } else relative(v.path)]
      if info.schema == null || info.crossedArray || !shapes.isScalar(info.schema)
    ];

function(input, output)
  local checked = [
    { link: link, problems: linkProblems(input, link) }
    for link in output.links
  ];
  {
    valid: output {
      operation: input.operation,
      links: [entry.link for entry in checked if std.length(entry.problems) == 0],
    },
    problems: std.flattenArrays([entry.problems for entry in checked]),
  }
