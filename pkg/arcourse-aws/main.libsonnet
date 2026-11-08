local a = import 'arcourse-ui/main.libsonnet';
local root = import 'root';

{
  accounts:: {},

  local accounts = self.accounts,

  nodeList:: [
    [['aws'], a.list.node {
      links: {
        ['%s (%s)' % [accounts[id].name, id]]: root.aws.account(id)
        for id in std.objectFields(accounts)
      },
    }],
    [['aws', '$account'], a.list.node {
      local node = self,
      links: {
        [region]: root.aws.account(node.account).region(region)
        for region in accounts[node.account].regions
      },
    }],
  ],
}
