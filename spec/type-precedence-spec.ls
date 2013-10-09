require!{
  \chai
  \type-check
}

{compare-types} = require '../src/type-precedence'
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
    that 'fixed vs. subset' ->
      expect compare-types '{x: Number}', '{...}' .to.eql -1
      expect compare-types '{...}', '{x: Number}' .to.eql 1
    that 'subset partially specified vs none' ->
      expect compare-types '{x: Number, ...}', '{...}' .to.eql -1
    describe 'recursive' ->
      that 'fixed' ->
        expect compare-types '{x: String}', '{x: *}' .to.eql -1
        expect compare-types '{x: String, y: *}', '{x: *, y: Number}' .to.eql 0
      that 'subset' ->
        expect compare-types '{x: String, ...}', '{x: *, ...}' .to.eql -1
        expect compare-types '{x: String, y: *, ...}', '{x: *, y: Number, ...}' .to.eql 0
  describe 'array' ->
    that 'generic vs explicit' ->
      expect compare-types '[*]', 'Array' .to.eql -1
    that 'recursive' ->
      expect compare-types '[String]', '[*]' .to.eql -1
      expect compare-types '[{x: *}]', '[{...}]' .to.eql -1
  describe 'tuple' ->
    describe 'recursive' ->
      that 'one' -> expect compare-types '(*)', '(Object)' .to.eql 1
      that 'more' -> expect compare-types '(*, *)', '(*, String)' .to.eql 1
  describe 'multiple types' ->
    that 'best match wins' ->
      expect compare-types 'Object | Array | String', 'Number | {x: *}', {x: 1} .to.eql 1
      expect compare-types 'Object | Array | String', 'Number | {x: *} | *', [1] .to.eql -1
    that 'first match wins when equal' ->
      expect compare-types 'String | Number', 'Number | String', \s .to.eql -1
      expect compare-types 'String | Number', 'Number | String', 21 .to.eql 1

