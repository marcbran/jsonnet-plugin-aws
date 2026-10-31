function(input, output)
  local problems =
    if output.decision == 'none' then []
    else if output.items == null then ['items is required when decision is "list"']
    else if !std.member(input.listCandidates, output.items) then [std.format('items %s is not one of listCandidates', [std.manifestJsonMinified(output.items)])]
    else [];
  {
    valid: output { operation: input.operation },
    problems: problems,
  }
