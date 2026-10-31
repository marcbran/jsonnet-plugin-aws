package resources

const resourcesPrompt = `Read input.json.

The AWS read operation in "operation" could not be placed in the resource tree, because no collection's items supply all of its required inputs. Decide where it belongs.

Return only JSON matching the provided schema.

Rules:
- "required" lists the operation's required input members and their schemas.
- "candidates" are the collections of the resource tree whose items are not identified yet. Each candidate already "provides" some input members through its ancestors. Identifying a candidate's items gives its child operations the identifier as additional inputs.
- Use decision "place" when the operation is clearly a child of one candidate's items: the candidate's "provides" plus the inputs built from one identifier field of its items must cover exactly the operation's required inputs.
- Only place an operation under a candidate whose items are the resource the operation is about. A candidate whose items merely contain a matching field (for example an image digest inside lifecycle policy preview results) is not a parent; the operation's documentation and name should describe a sub-resource or aspect of the candidate's items.
- For "place", set "collection" to that candidate's operation and describe in "id" how its items are identified:
  - "param" names the path parameter, usually the identifier field's own name, for example "imageDigest".
  - "path" is the property path of the identifier within an item of "itemSchema", for example ["imageDigest"]. It must resolve to a single scalar value.
  - "inputs" lists every required input member path that receives the identifier, for example [{"path": ["imageId", "imageDigest"]}] when the operation takes a structured "imageId" input.
  - "filter" is set when the candidate's own list operation can be narrowed to a single item through one of its "listInputs": "member" names that list input and "itemPath" is the path within one list element that receives the identifier ([] when the elements are the identifiers themselves). Use null otherwise.
- Use decision "skip" with "collection" and "id" set to null when the operation does not belong under any candidate, for example when it applies to many resource types through an ARN, needs a free-form argument such as a setting name, or needs inputs no collection supplies.
- Prefer "skip" over a placement you are not confident about.
`

const itemsPrompt = `Read input.json.

The AWS read operation in "operation" is paginated, but its model does not say which list in the response is paged. "listCandidates" are the lists found in "outputSchema"; each is a property path from the response root.

Return only JSON matching the provided schema.

Rules:
- Use decision "list" and set "items" to exactly one path from "listCandidates": the list whose elements are what the operation pages through and what an operator would browse as table rows.
- Use the operation's name and documentation to decide; prefer the list that holds the primary records the operation is about over secondary or alternative representations, unless the documentation says otherwise.
- Use decision "none" with "items" set to null only when none of the candidates is the paged list.
`
