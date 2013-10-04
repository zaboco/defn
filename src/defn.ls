require! \type-check .type-check
{keys, find} = require \prelude-ls

function ensure-tuple then it.replace /^([^(].*)/ "($1)"

class Defs
  -> @fns = {}
  signatures:~ -> keys @fns
  add: (fn) -> @fns['(*)'] = fn
  get: (sig) -> @fns[ensure-tuple sig]
  contains: (sig) -> (@get sig)?
  signature-of: (args)-> @signatures |> find type-check _, args
  get-impl-for: (args) -> @get @signature-of args
  apply: (obj, args) -> (@get-impl-for args).apply obj, args

class Defn
  -> @__defs__ = new Defs
  signatures: -> @__defs__.signatures
  has-signature: -> @__defs__.contains it
  can-call: (...args) -> (@__defs__.signature-of args)?
  define: -> @__defs__.add it
  apply: (obj, args) -> @__defs__.apply obj, args
  call: (obj, ...args) -> @__defs__.apply obj, args

init = ->
  main-fn = (...args) ->
    main-fn.apply @, args

  main-fn <<<< new Defn

defn = ->
  init ...

defn.init = init

module.exports = defn

