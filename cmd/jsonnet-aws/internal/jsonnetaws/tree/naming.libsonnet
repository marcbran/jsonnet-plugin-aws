local verbs = ['BatchGet', 'Describe', 'List', 'Get', 'Head'];

local upperRun(s) =
  local chars = std.stringChars(s);
  std.foldl(function(acc, c) if acc.done then acc else if c >= 'A' && c <= 'Z' then acc { n: acc.n + 1 } else acc { done: true }, chars, { n: 0, done: false }).n;

local lowerFirst(s) =
  local n = upperRun(s);
  local rest = s[n:];
  if s == '' then s
  else if n <= 1 then std.asciiLower(s[0]) + s[1:]
  else if rest == '' || rest == 's' then std.asciiLower(s[:n]) + rest
  else std.asciiLower(s[:n - 1]) + s[n - 1:];

local upperFirst(s) = if s == '' then s else std.asciiUpper(s[0]) + s[1:];

local endsWith(s, suffix) = std.endsWith(s, suffix);

local isUpper(c) = c >= 'A' && c <= 'Z';

local words(s) =
  local chars = std.stringChars(s);
  local n = std.length(chars);
  local boundary(i) = isUpper(chars[i]) && (!isUpper(chars[i - 1]) || (i + 1 < n && !isUpper(chars[i + 1])));
  local starts = [0] + [i for i in std.range(1, n - 1) if boundary(i)];
  local ends = starts[1:] + [n];
  [std.join('', chars[starts[k]:ends[k]]) for k in std.range(0, std.length(starts) - 1)];

local isAcronym(word) = std.length(word) > 1 && std.asciiUpper(word) == word;

{
  verb(operation)::
    local matching = [v for v in verbs if std.startsWith(operation, v)];
    if std.length(matching) == 0 then null else matching[0],

  noun(operation)::
    local verb = self.verb(operation);
    local noun = if verb == null then operation else operation[std.length(verb):];
    local chars = std.stringChars(noun);
    local trailing = std.foldr(function(c, acc) if acc.done then acc else if c >= '0' && c <= '9' then acc { n: acc.n + 1 } else acc { done: true }, chars, { n: 0, done: false }).n;
    local v = std.length(noun) - trailing - 1;
    local unversioned = if trailing > 0 && v > 0 && noun[v] == 'V' then noun[:v] else noun;
    if std.length(unversioned) > 5 && endsWith(unversioned, 'Names') then unversioned[:std.length(unversioned) - 5] + 's' else unversioned,

  singular(s)::
    if endsWith(s, 'ies') then s[:std.length(s) - 3] + 'y'
    else if endsWith(s, 'sses') || endsWith(s, 'uses') || endsWith(s, 'xes') || endsWith(s, 'ches') || endsWith(s, 'shes') || endsWith(s, 'zes') then s[:std.length(s) - 2]
    else if endsWith(s, 's') && !endsWith(s, 'ss') then s[:std.length(s) - 1]
    else s,

  lowerFirst(s):: lowerFirst(s),

  upperFirst(s):: upperFirst(s),

  stripPrefix(s, prefix)::
    if prefix == null || std.length(s) <= std.length(prefix) then s
    else if std.asciiLower(s[:std.length(prefix)]) == std.asciiLower(prefix) then s[std.length(prefix):]
    else s,

  label(name)::
    local parts = words(upperFirst(name));
    std.join(' ', [parts[0]] + [if isAcronym(p) then p else std.asciiLower(p) for p in parts[1:]]),
}
