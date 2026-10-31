local p = import 'pkg/main.libsonnet';

p.pkg({
  source: 'https://github.com/marcbran/jsonnet-plugin-aws/tree/main/arcourse',
  repo: 'https://github.com/marcbran/jsonnet.git',
  branch: 'arcourse/aws/arcourse-aws',
  path: 'arcourse/aws/arcourse-aws',
  target: 'arcourse-aws',
  external: ['root', 'arcourse-ui/main.libsonnet'],
}, |||
  Arcourse entry nodes for AWS: the `aws` node listing the configured accounts and the
  `aws/$account` nodes listing their regions. Services come from the `arcourse-aws-<service>`
  packages, which link themselves from the region nodes.
|||, {
  accounts: p.desc(|||
    Accounts to browse, as `{ [accountId]: { name, regions: [...] } }`; none by default.
  |||),
  nodeList: p.desc(|||
    The `aws` and `aws/$account` nodes for the configured accounts.
  |||),
})
