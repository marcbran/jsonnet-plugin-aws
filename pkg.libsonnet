local p = import 'pkg/main.libsonnet';

p.pkg({
  source: 'https://github.com/marcbran/jsonnet-plugin-aws',
  repo: 'https://github.com/marcbran/jsonnet.git',
  branch: 'plugin/aws',
  path: 'plugin/aws',
  target: 'aws',
}, |||
  Read-only calls against AWS service APIs, driven by the services' Smithy models. Services and credentials are configured when the plugin is started or embedded in Go.
|||, {
  call: p.desc(|||
    Calls a read operation (`Describe*`, `List*`, `Get*`, `Head*`, `BatchGet*`). `ctx` is `{ account, region }`, `service` is the
    lowercased SDK id (e.g. `ecr`), `operation` is the operation name and `input` its input structure with model member names.
    Null members are omitted. Pagination tokens and page sizes are ordinary input and output members.

    On success returns the decoded output structure. On failure returns a `Status` object (`kind: "Status"`).
  |||),
})
