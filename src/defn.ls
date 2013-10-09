require! {
  \type-check .type-check
  './type-precedence' .best-type
}

{keys, find} = require \prelude-ls

function ensure-tuple (signature='')
  signature.replace /^([^(].*)/ "($1)"

class Defs
  -> @fns = {}
  signatures:~ -> keys @fns
  add: -> switch typeof! &0
    | \Function => @add-default &0
    | \String => @add-one &0, &1
    | \Object => @add-more &0
  add-default: (fn) -> @fns['(*)'] = fn
  add-one: (sig, fn) -> @fns[ensure-tuple sig] = fn
  add-more: (map) -> for sig, fn of map then @add-one sig, fn
  get: (sig) -> @fns[ensure-tuple sig]
  contains: (sig) -> (@get sig)?

  throw-unimplemented: ->
    throw new Error "Unimplemented: fn requires one of #{@signatures}"
  signature-of: (args)-> best-type in: @signatures, matching: args
  get-impl-for: (args) ->
    @get @signature-of args or @throw-unimplemented!
  apply: (obj, args) -> (@get-impl-for args).apply obj, args

class Defn
  -> @__defs__ = new Defs
  signatures: -> @__defs__.signatures
  has-signature: -> @__defs__.contains it
  can-call: (...args) -> (@__defs__.signature-of args)?
  define: -> @__defs__.add &0, &1; @
  apply: (obj, args) -> @__defs__.apply obj, args
  call: (obj, ...args) -> @__defs__.apply obj, args

init = ->
  main-fn = (...args) ->
    main-fn.apply @, args

  main-fn <<<< new Defn

defn = (...args) ->
  fn = init!
  fn.define.apply fn, args

defn.init = init

module.exports = defn

