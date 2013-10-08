{parse-type: pt, type-check: tc} = require \type-check

__ = -> true

check-same-pairs = ([xa, xb], [ya, yb]) ->
  xa is ya and xb is yb or xa is yb and xb is ya

check-order = (of: [a, b], using: [pa, pb]) ->
  | a is b => 0
  | pa a and pb b => -1
  | pa b and pb a => 1
  | _ => false

compare = ([a, b]) -->
  | a < b => -1
  | b > a => 1
  | _ => 0

compare-by = (fn, [a, b]) -->
  compare [(fn a), (fn b)]


compare-parsed = (...[a, b]:args) ->
  | (typeof! a) is \Array => compare-parsed a.0, b.0
  | a.type? and b.type? => compare-parsed a.type, b.type
  | sign = check-order of: args, using: [(.structure?), (.type?)] => sign
  | sign = check-order of: args, using: [(not) << (.subset), (.subset)] => sign
  | sign = check-order of: args, using: [__, (is \*)] => sign
  | a.subset? and b.subset? => args |> compare-by -> -(Object.keys it.of .length)
  | _ => 0

compare-types = (ta, tb) ->
  compare-parsed (pt ta), (pt tb)

module.exports = {compare-types, cp: compare-parsed}

STRUCT_PREC = 30
TYPE_PREC = 40
SUBSET_PREC = 50
WILDCARD_PREC = 100
