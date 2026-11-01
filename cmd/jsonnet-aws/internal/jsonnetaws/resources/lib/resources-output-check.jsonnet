local shapes = import 'shapes.libsonnet';

local placeProblems(input, output) =
  local matches = [c for c in input.candidates if c.operation == output.collection];
  if std.length(matches) == 0 then [std.format('collection %s is not one of the candidates', [output.collection])]
  else
    local candidate = matches[0];
    local id = output.id;
    if id == null then ['id is required when decision is "place"']
    else if candidate.itemSchema == null then [std.format('collection %s has no item schema to identify items by', [output.collection])]
    else
      local field = shapes.at(candidate.itemSchema, id.path);
      local heads = std.set([i.path[0] for i in id.inputs if std.length(i.path) > 0]);
      local covered = std.setUnion(std.set(candidate.provides), heads);
      local required = std.set(std.objectFields(input.required));
      (if field.schema == null then [std.format('id path %s does not exist in the item schema', [std.manifestJsonMinified(id.path)])]
       else if field.crossedArray || !shapes.isScalar(field.schema) then [std.format('id path %s must resolve to a single scalar value', [std.manifestJsonMinified(id.path)])]
       else []) +
      (if std.length(id.inputs) == 0 then ['id.inputs must map the identifier onto at least one input member'] else []) +
      [
        std.format('input path %s does not start with a required input member', [std.manifestJsonMinified(i.path)])
        for i in id.inputs
        if std.length(i.path) == 0 || !std.member(required, i.path[0])
      ] +
      (if covered != required then [std.format('provided %s plus id inputs %s must equal the required inputs %s', [std.manifestJsonMinified(candidate.provides), std.manifestJsonMinified(heads), std.manifestJsonMinified(required)])] else []) +
      (if id.filter != null && !std.member(candidate.listInputs, id.filter.member) then [std.format('filter member %s is not a list input of %s', [id.filter.member, output.collection])] else []);

function(input, output)
  local problems =
    if output.decision == 'skip' then []
    else placeProblems(input, output);
  {
    valid: output { operation: input.operation },
    problems: problems,
  }
