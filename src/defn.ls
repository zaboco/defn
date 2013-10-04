require! \type-check .type-check

defn-proto = (fn) ->
  __fns__: []
  signatures: []
  has-signature: -> false
  can-call: -> false

init = ->
  fn = ->
  fn <<< defn-proto fn

defn = ->
  init ...

defn.init = init

module.exports = defn

