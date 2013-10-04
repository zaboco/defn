require! {
  '../src/defn'
  \chai
  \chai-signature
  \sinon
  \sinon-chai
}
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
describe 'defn' ->
  describe 'after init' ->
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
      that 'signatures is [(*)]' ->
        expect fn.signatures! .to.eql <[ (*) ]>
      that 'has signature (*)' ->
        expect fn.has-signature '(*)' .to.be.true
      that 'has signature *' ->
        expect fn.has-signature '*' .to.be.true
      that 'can call anything' ->
        expect fn.can-call 1 .to.be.true
      that 'calling redirects to the defined fn' ->
        fn 1
        expect spy .to.have.been.called

    describe '#define fn with @ inside' ->
      var impl
      before-each ->
        fn.define impl := -> "#@:#it"
      that 'can use with Function.call' ->
        expect fn.call \x, 1 .to.eql "x:1"
      that 'can use with Function.apply' ->
        expect fn.apply \x, [1] .to.eql "x:1"

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
        expect fn .called-with \2 .to.throw 'Unimplemented: fn requires one of (Number)'
