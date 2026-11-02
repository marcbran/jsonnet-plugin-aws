package links

const linksPrompt = `Read input.json.

Identify every place in the response of the AWS operation in "operation" that references another resource listed in "targets", so it can link to that resource's page.

Return only JSON matching the provided schema: an object with a "links" array, empty if none found.

Rules:
- "responseSchema" describes the operation's response. When "at" in input.json is not null, the response is a list whose items sit at that path; its rows already link to their own pages, so only report references to other resources.
- Each link's "at" is a property path, relative to the response root, to the object that holds the reference. Naming an array property in the path means "once per element of that array"; never write "[]" or indices into any path. Use [] only when the reference sits directly on the response root. When the references are an array of plain identifiers (for example "SecurityGroupIds"), let "at" end with that array; the element itself is then the identifier, written as the path [].
- When "at" in input.json is not null, the response is a list and a reference held by each item must have an "at" that starts with that path: for example, with "at": ["NatGateways"], a NAT gateway's VPC is the link "at": ["NatGateways"] with the var path ["VpcId"], and its addresses are "at": ["NatGateways", "NatGatewayAddresses"].
- "target" must be exactly one "operation" from "targets". Do not invent targets.
- "targets" may include the response's own resource type and the types of the resources that contain it (its parents, visible in "path"). Use them only for references to other items of those types, for example a security group rule that references another security group, or a bucket's logging configuration that names its target bucket. Never link an item to itself or to the parent it belongs to; breadcrumbs already cover those.
- "vars" must give a value for every one of the target's "params", as a property path relative to the object at "at" ([] when the element at "at" is the identifier itself). Paths must resolve to a single scalar value and must not cross arrays.
- Match identifiers by meaning: a "VpcId" field refers to the VPC collection identified by "VpcId"; an ARN only matches when the target is identified by an ARN.
- "keys" labels each link for operators, as segments: {"const": "<label>", "path": null} for a fixed label naming the relationship (for example "vpc" or "security groups", never a raw field name like "VpcId"), and {"const": null, "path": [...]} for a value relative to "at". Add a trailing path segment whenever "at" crosses an array so entries stay distinct; use [] when the element itself is the value.
- Only report references you are confident about; skip fields that merely look like identifiers.
`
