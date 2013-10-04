require! \type-check .type-check
{keys, find} = require \prelude-ls

function ensure-tuple then it.replace /^([^(].*)/ "($1)"

class Defs
  -> @fns = {}
  signatures:~ -> keys @fns
  add: (fn) -> @fns['(*)'] = fn
  get: (sig) -> @fns[ensure-tuple sig]
  contain: (sig) -> (@get sig)?
  signature-of: (args)-> @signatures |> find type-check _, args
  get-impl-for: (args) -> @get @signature-of args
  apply-for: (args) -> (@get-impl-for args).apply @, args

class Defn
  -> @__defs__ = new Defs
  signatures: -> @__defs__.signatures
  has-signature: -> @__defs__.contain it
  can-call: (...args) -> (@__defs__.signature-of args)?
  define: -> @__defs__.add it
  call-for: (...args) -> @__defs__.apply-for args

init = ->
  main-fn = (...args) ->
    main-fn.call-for.apply main-fn, args

  main-fn <<<< new Defn

defn = ->
  init ...

defn.init = init

module.exports = defn

