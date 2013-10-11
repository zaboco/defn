require! 'type-precedence' .best-type

function ensure-tuple (signature='')
  signature.replace /^([^(].*)/ "($1)"

function ensure-valid (signature='') then switch
  | signature is '...' => '[*]'
  | matches = signature.match /\.{3}(.*)/ => "[#{matches.1}]"
  | _ => ensure-tuple signature

class Defs
  -> @fns = {}
  signatures:~ -> Object.keys @fns
  add: -> switch typeof! &0
    | \Function => @add-default &0
    | \String => @add-one &0, &1
    | \Object => @add-more &0
  add-default: (fn) -> @fns['[*]'] = fn
  add-one: (sig, fn) -> @fns[ensure-valid sig] = fn
  add-more: (map) -> for sig, fn of map then @add-one sig, fn
  get: (sig) -> @fns[sig]
  contains: (sig) -> (@get ensure-valid sig)?

  throw-unimplemented: (args) ->
    throw new Error "Can't call on #{[.. for args]}: fn requires one of #{@signatures}"
  signature-of: (args)-> best-type in: @signatures, matching: args
  get-impl-for: (args) ->
    @get @signature-of args or @throw-unimplemented args
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

