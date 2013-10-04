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
    that 'has signatures property' ->
      expect fn .to.have.property \signatures
    that 'responds to #has-signature' ->
      expect fn .itself.to.respond-to \hasSignature
    that 'has no signatures' ->
      expect fn.signatures .to.be.empty
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
      that.skip 'signatures is [(*)]' ->
        expect fn.signatures .to.eql <[ (*) ]>
