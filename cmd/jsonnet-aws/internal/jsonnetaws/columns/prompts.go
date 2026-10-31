package columns

const columnsPrompt = `Read input.json.

Choose useful table-view columns for the items of the AWS list operation in "operation". "array" is where the items sit in the response, "itemSchema" describes one item.

Return only JSON matching the provided schema.

Rules:
- Choose roughly 3 to 6 columns.
- Column paths must be property paths relative to the list item, for example ["repositoryName"] or ["imageScanningConfiguration", "scanOnPush"].
- If itemSchema is a scalar value rather than an object, return a single column with path [] to show the item itself.
- Do not invent properties that are not supported by itemSchema.
- Prefer names, states and statuses, timestamps, small counts, and concise scalar fields.
- Operators recognize resources by name. When an item has both a name (or a "Name" tag) and an opaque identifier, make the name primary; keep the identifier as a secondary column only when it is what operators copy around (for example an EC2 instance or VPC id).
- Avoid ARNs, URIs, descriptions, policy documents, blobs, nested arrays, and large object values unless they are clearly useful as table columns.
- Use priority "primary" for the main identifying column, "secondary" for generally useful columns and "tertiary" for lower-value columns.
- Use kind values that describe display intent, such as "identifier", "name", "status", "timestamp", "count", "text", "number", or "boolean".
- Keep labels short and human-readable.
`
