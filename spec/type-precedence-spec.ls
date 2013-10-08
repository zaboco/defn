require!{
  \chai
  \type-check
}

{compare-types, cp} = require '../src/type-precedence'
{reverse, all, sort-with} = require \prelude-ls
{expect} = chai
{type-check, parse-type: pt} = type-check

ok = chai.assert.ok
that = it


function suite types, target, {equal=false} = {}
  that 'all types match target' ->
    expect all (type-check _, target), types .to.be.true

  that "#{types.0} precedes #{types.1}" ->
    first-prec = precedence types.0
    second-prec = precedence types.1
    switch
      | equal => expect first-prec, target .to.eql second-prec, target
      | _ => expect first-prec, target .to.be.lt second-prec, target


describe 'compare-types' ->
  describe 'wildcard' ->
    that 'first' -> expect compare-types \*, \String .to.eql 1
    that 'second' -> expect compare-types \String, \* .to.eql -1
    that 'equal' -> expect compare-types \*, \* .to.eql 0
    that 'sort' -> expect sort-with compare-types, [\* \Number] .to.eql [\Number \*]
  describe 'object' ->
    that 'generic vs explicit' ->
      expect compare-types '{x: Number}', 'Object' .to.eql -1
      expect compare-types 'Object', '{x: Number}' .to.eql 1
    that 'fix vs. subset' ->
      expect compare-types '{x: Number}', '{...}' .to.eql -1
      expect compare-types '{...}', '{x: Number}' .to.eql 1
    that 'subset partially specified vs none' ->
      expect compare-types '{x: Number, ...}', '{...}' .to.eql -1

