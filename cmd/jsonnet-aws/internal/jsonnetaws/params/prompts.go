package params

const paramsPrompt = `Read input.json.

Classify every input parameter of the AWS list operation in "operation" by the role it plays when listing items. "params" lists the parameters with their type, enum values and documentation.

Return only JSON matching the provided schema.

Roles:
- "filter": narrows which items are returned, for example a list of ids or names, a status, an engine, a path or key prefix, or a flag that includes or excludes a category of items.
- "shaping": changes what each item or the response contains without changing which items are returned, for example including extra attributes, fetching owner details, or loading a related configuration.
- "pagination": controls which page is returned or how many items it holds, for example MaxResults, MaxKeys, NextToken, Marker, ContinuationToken, StartAfter, or KeyMarker.
- "sort": controls the order of the items.
- "other": anything that fits none of the above, for example a dry-run flag, an encoding type, or a request that triggers an action.

Rules:
- Classify every parameter in params exactly once, using its name as given.
- Use the documentation, type, and enum values, not only the name.
- A parameter that names the position to continue listing from is "pagination", even when it looks like an identifier.
- When a parameter both narrows and reshapes the response, prefer "filter".
- Keep reasons short.
`
