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
  describe 'array' ->
    that 'generic vs explicit' ->
      expect compare-types '[*]', 'Array' .to.eql -1

