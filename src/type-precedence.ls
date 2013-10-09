{sort-with, find, map, zip-with, values} = require \prelude-ls
{parse-type: pt, type-check: tc} = require \type-check

__ = -> true # wildcard, matches anything in check-order

# checks order using predicates
check-order = (of: [a, b], using: [pa, pb]) ->
  | a is b => 0
  | pa a and pb b => -1
  | pa b and pb a => 1
  | _ => false

compare = ([a, b]) -->
  | a < b => -1
  | b > a => 1
  | _ => 0

compare-by = (comparator, [a, b]) -->
  compare [(comparator a), (comparator b)]

# assumes lists same size
compare-lists-with = (comparator, la, lb) -->
  [la, lb] = map (sort-with comparator), [la, lb]
  (find (!= 0), zip-with comparator, la, lb) ? 0

n-keys = (obj) ->
  Object.keys obj .length

different-size-subsets = (a, b) ->
  a.subset? and b.subset? and (n-keys a.of) isnt (n-keys b.of)

both-are-structure = (structure, a, b) ->
  a.structure is b.structure is structure

compare-all-fields-values = (a, b) ->
  compare-lists-with compare-parsed, (values a.of), (values b.of)

compare-all-tuple-items = (a, b) ->
  compare-lists-with compare-parsed, a.of, b.of

compare-parsed = (...[a, b]:args) ->
  | (typeof! a) is (typeof! b) is \Array => compare-parsed a.0, b.0
  | a.type? and b.type? => compare-parsed a.type, b.type
  | sign = check-order of: args, using: [(.structure?), (.type?)] => sign
  | sign = check-order of: args, using: [(not) << (.subset), (.subset)] => sign
  | sign = check-order of: args, using: [__, (is \*)] => sign
  | different-size-subsets a, b => args |> compare-by -> -(n-keys it.of)
  | both-are-structure \array, a, b => compare-parsed a.of, b.of
  | both-are-structure \fields, a, b => compare-all-fields-values a, b
  | both-are-structure \tuple, a, b => compare-all-tuple-items a, b
  | _ => 0

compare-types = (ta, tb, target) ->
  compare-parsed (pt ta), (pt tb)

module.exports = {compare-types, cp: compare-parsed, compare-lists-with}

STRUCT_PREC = 30
TYPE_PREC = 40
SUBSET_PREC = 50
WILDCARD_PREC = 100
