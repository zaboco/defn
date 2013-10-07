{sort-with, sort-by} = require \prelude-ls
{parse-type: pt, type-check: tc} = require \type-check

function sort types, target
  # console.log com
  sort-by precedence, types

function precedence type
  prec-parsed pt type

prec-parsed = (ptype) -> switch ptype.length
  | 1 => prec-of-one ptype.0
  | _ => prec-of-more ptype

prec-of-one = (tdef) ->
  | tdef.type? => prec-of-type tdef.type
  | tdef.structure? => prec-of-struct tdef

prec-of-type = (type) -> switch type
  | \* => 0
  | _ => 100

prec-of-struct = (tdef) ->
  10


module.exports = {sort}

