require!{
  \chai
  \type-check
  '../src/type-precedence' .sort
}

{reverse, all} = require \prelude-ls
{expect} = chai
{type-check, parse-type: pt} = type-check

that = it

describe 'sort by precedence' ->
  var types, target
  describe 'wildcard',
    suite ['*' 'Number'], 1
  describe 'Object: generic vs. explicit',
    suite ['{x: Number}', 'Object'], {x: 1}
  describe 'Array: generic vs. explicit',
    suite ['[Number]', 'Array'], [1 2]

function suite types, target then ->
  that 'all types match target' ->
    expect all (type-check _, target), types .to.be.true
  that 'sorted list same as orginal' ->
    expect sort types, target .to.eql types
  that 'sorted reverse list same as orginal' ->
    expect sort reverse types .to.eql types
