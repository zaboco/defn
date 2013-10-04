require! {
  '../src/defn'
  \chai
  \chai-signature
}
chai.use chai-signature
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
    that 'responds to #can-call' ->
      expect fn .itself.to.respond-to \canCall
    that 'cannot call anything' ->
      expect fn.can-call void .to.be.false

    describe '#define one w/o type' ->
      var impl
      before-each ->
        impl := -> it
        fn.define impl
      that 'signatures is [(*)]' ->
        expect fn.signatures! .to.eql <[ (*) ]>
      that 'has signature (*)' ->
        expect fn.has-signature '(*)' .to.be.true
      that 'has signature *' ->
        expect fn.has-signature '*' .to.be.true
      that 'can call anything' ->
        expect fn.can-call 1 .to.be.true
      that 'calling redirects to the defined fn' ->
        expect fn 1 .to.eql 1
