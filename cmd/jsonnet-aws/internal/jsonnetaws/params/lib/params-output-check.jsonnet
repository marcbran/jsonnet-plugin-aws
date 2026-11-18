function(input, output)
  local outputParams = std.get(output, 'params', []);
  local inputNames = [param.name for param in input.params];
  local outputNames = [param.name for param in outputParams];
  local known = [param for param in outputParams if std.member(inputNames, param.name)];
  local unique = [
    known[i]
    for i in std.range(0, std.length(known) - 1)
    if std.count([param.name for param in known[0:i]], known[i].name) == 0
  ];
  {
    valid: output {
      operation: input.operation,
      params: unique,
    },
    problems: [
      std.format('param %s does not exist in input.json', [name])
      for name in std.set(outputNames)
      if !std.member(inputNames, name)
    ] + [
      std.format('param %s is classified more than once; classify each param exactly once', [name])
      for name in std.set(outputNames)
      if std.count(outputNames, name) > 1
    ] + [
      std.format('param %s from input.json is missing; classify every param', [name])
      for name in inputNames
      if !std.member(outputNames, name)
    ],
  }
