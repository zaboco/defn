require! {
  '../src/defn'
  \chai
  \chai-signature
  \sinon
  \sinon-chai
}
require "better-stack-traces" .install do
  before: 2
  after: 2

chai.use chai-signature
chai.use sinon-chai
expect = chai.expect

/*
  fn = defn.init

  fn.signatures
  fn.has-signature (sig)
  fn.can-call (args)

  fn.define [fn:Function]
  fn.define [signature:String], [fn:Function]
  fn.define [signatures-map:Object]
*/

that = it
describe 'defn.init' ->
  var fn
  before-each -> fn := defn.init!
  that 'has method #signatures' ->
    expect fn.signatures .to.be.a \Function
  that 'has method #has-signature' ->
    expect fn.has-signature .to.be.a \Function
  that 'has no signatures' ->
    expect fn.signatures! .to.be.empty
    expect fn.has-signature \* .to.be.false
  that 'has method #can-call' ->
    expect fn.can-call .to.be.a \Function
  that 'cannot call anything' ->
    expect fn.can-call void .to.be.false
  that 'has method #call' ->
    expect fn.call .to.be.a \Function
  that 'has method #apply' ->
    expect fn.apply .to.be.a \Function

  describe '#define one w/o signature' ->
    var spy
    before-each ->
      fn.define spy := sinon.spy!
    that 'signatures is [[*]]' ->
      expect fn.signatures! .to.eql <[ [*] ]>
    that 'has signature ...' ->
      expect fn.has-signature '...' .to.be.true
    that 'can call anything' ->
      expect fn.can-call 1, 2 .to.be.true
      expect fn.can-call undefined .to.be.true
    that 'calling redirects to the defined fn' ->
      fn 1; expect spy .to.have.been.called

  describe '#define fn with @ inside' ->
    var impl
    before-each ->
      fn.define impl := -> "#@:#it"
    that 'can use with Function.call' ->
      expect fn.call \x, 1 .to.eql "x:1"
    that 'can use with Function.apply' ->
      expect fn.apply \x, [1] .to.eql "x:1"

  describe '#define one w/ ... signature' ->
    var spy
    before-each ->
      fn.define '...', spy := sinon.spy!
    that 'signatures is [[*]]' ->
      expect fn.signatures! .to.eql <[ [*] ]>
    that 'has signature ...' ->
      expect fn.has-signature '...' .to.be.true
    that 'can call anything' ->
      expect fn.can-call 1, 2 .to.be.true
      expect fn.can-call undefined .to.be.true

  describe '#define one w/ signature' ->
    before-each ->
      fn.define \Number (n) -> n + 1
    that 'signatures is [(Number)]' ->
      expect fn.signatures! .to.eql <[ (Number) ]>
    that 'has signature (Number)' ->
      expect fn.has-signature '(Number)' .to.be.true
    that 'has signature Number' ->
      expect fn.has-signature 'Number' .to.be.true
    that 'can call a number' ->
      expect fn.can-call 1 .to.be.true
    that 'cannot call anything else' ->
      expect fn.can-call \2 .to.be.false
    that 'calling something else throws error' ->
      expect fn .called-with \2 .to.throw "Can't call on 2: fn requires one of (Number)"

  describe '#define one w/ ...String signature' ->
    before-each ->
      fn.define \...String (...args) -> "#args are string"
    that 'signatures is [[String]]' ->
      expect fn.signatures! .to.eql <[ [String] ]>
    that 'has signature ...String' ->
      expect fn.has-signature '...String' .to.be.true
    that 'can call one String' ->
      expect fn.can-call \a .to.be.true
    that 'can call more Strings' ->
      expect fn.can-call \a, \b .to.be.true
    that 'cannot call anything else' ->
      expect fn.can-call 2 .to.be.false
    that 'calling something else throws error' ->
      expect fn .called-with 1 .to.throw "Can't call on 1: fn requires one of [String]"
    that 'calling it works' ->
      expect fn \s .to.be.ok

  describe '#define more' ->
    spy = {}
    before-each ->
      fn.define do
        Number: spy.number := sinon.spy!
        String: spy.string := sinon.spy!
        '*': spy.default := sinon.spy!
    that 'signatures are Number, String, *' ->
      expect fn.signatures! .to.eql <[(Number) (String) (*)]>
    describe 'the right implementation is called' ->
      that 'for a number' ->
        fn 1; expect spy.number .to.have.been.called
      that 'for a string' ->
        fn \1; expect spy.string .to.have.been.called
      that 'for anything else' ->
        fn []; expect spy.default .to.have.been.called

describe 'defn' ->
  var fn, spy
  that 'works' ->
    fn := defn spy := sinon.spy!
    fn 1; expect spy .to.have.been.called-with 1
  describe 'chain' ->
    before-each ->
      fn := defn 'Number' -> 1
        .define 'String' -> \s
        .define '[*]' -> \array
    that 'has Number signature' ->
      expect fn.has-signature \Number .to.be.true
    that 'has String signature' ->
      expect fn.has-signature \String .to.be.true
    that 'has Array in signature' ->
      expect fn.has-signature '[*]' .to.be.true
    that 'can call a number' ->
      expect fn.can-call 0 .to.be.true
    that 'call to array works' ->
      expect fn [1 \1] .to.eql \array
  describe 'signature precedence' ->
    before-each ->
      fn := defn do
        '*': -> \other
        'Number': -> \number
    that 'calls most specific match' ->
      expect fn 1 .to.eql \number
