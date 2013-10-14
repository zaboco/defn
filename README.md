# defn [![Build Status](https://travis-ci.org/zaboco/defn.png?branch=master)](https://travis-ci.org/zaboco/defn)

`defn` is a used to define/overload functions with type signature. It uses [`type-check`](https://github.com/gkz/type-check) for choosing the signature that matches the arguments, and [`type-precedence`](https://github.com/zaboco/type-precedence) to choose the most specific signature.

```sh
$ npm install defn
```
## Signature definition
`defn` supports all the [types that can be checked with `type-check`](https://github.com/gkz/type-check#type-format) for arguments signature. It assumes that the signature is a tuple, but the pharantesis are not required. So, `(Number, Number)` and `Number, Number` are equivalent. However, a special type notation is added, `...Type`, which means that all the arguments are of type `Type` (`...` matches any arguments with any type). So, here are few examples of signatures:

* `...` - translates to `[*]` -> matches anything
* `...String` - translated to `[String]` -> matches `f(\a)`, `f(\a, \b)`, etc
* `[*]` - translates to `([*])` -> matches `f([1 2 3])`, but doesn't match `f(1, 2, 3)`
* `Number | String` -> matches `f(1)` or `f(\a)`, but not `f(1, \a)`
* `{x: Number, y: Number}` -> matches `f({x: 1, y: 1})`

## Usage
```ls
require! \defn
fn = defn \String, (s) -> "#s is a string"
fn.overload \Number, (n) -> "#n is a number"

fn \s # "s is a string"
fn 1 # "1 is a number"
```

### defn(fn-impl)
Defines a function with a implementation without a signature (assumes `...` as default)
```ls
fn = defn -> it
fn 1 # 1
fn \a # 'a'
```

### defn(signature, fn-impl)
Defines a function with an implementation having the provided signature
```ls
fn = defn \String -> '#it is a string'
fn \a # 'a is a string'
fn 1 # throws Error - Can't call on 1: fn requires one of (String)
```

### defn(definitions)
Defines a function with multiple signatures
```ls
{fold, reject} = require \prelude-ls

diff = defn do
  'Number, Number': (a, b) -> a - b
  '[Number], Number': (list, item) -> reject (is item), list
  '[Number], [Number]': (list, sublist) -> fold diff, list, sublist

diff 1, 2 # -1
diff [1 2 3 1], 1 # [2 3]
diff [1 2 3 1], [1 2] # [3]
```

### fn.overload(...)
_Same usage as for `defn(...)`_
```ls
fn = defn -> 'default'
fn.overload '...String' -> 'string args'

fn \a, \b # 'string'
fn [1 2] # 'default'
```

### fn.signatures()
Returns all signatures defined for the function
```ls
fn = defn do
  '...' -> 'default'
  '{x: *, y: *}' -> 'x:y'
  'Number, Number' -> 'n,n'

fn.signatures! # ['[*]' '({x: *, y: *})' '(Number, Number)']
```

### fn.has-signature(sig)
Checks that a certain signature is defined for `fn`
```ls
fn = defn -> 'default'
fn.overload \String -> '#it is a string'

fn.has-signature '...' # true
fn.has-signature 'String' # true
fn.has-signature '(String)' # true
fn.has-signature '[*]' # false
```

### fn.can-call(args)
Returns true if the arguments `args` can be called on `fn`
```ls
fn = defn \Number -> 0

fn.can-call 1 # true
fn.can-call 1, 2 # false
fn.can-call [1] # false
```
  
### fn.call(...), fn.apply(...)
Overriden `Function` methods. Will point to the implementation matched by the provided arguments
```ls
fn = defn \Number -> @.number + it
fn.overload \String -> @.string + it

obj = number: 1, string: \s

fn.call obj, 20 # 21
fn.apply obj, [\tring] # 'string'
```

## Misc
### Chains
`defn` and `overload` are chainable:
```ls
fn = defn -> 'default'
  .overload \String -> 's'
  .overload \Number -> 0

fn.signatures! # ['[*]' '(String)' '(Number)']
```

### Defs Overwrites
If a signature gets another implementation, it overwrites the previous
```ls
fn = defn -> 'default'
fn.overload -> 'the new default'

fn! # 'the new default'
```

### Signature precedence
The order in which the signatures are defined is irelevant: the most specific signature for the given arguments is chosen each time, using [`type-precedence`](https://github.com/zaboco/type-precedence#type-precedence):
```ls
fn = defn do
  '...' -> default
  \Array -> 'a generic array'
  '[Number]' -> 'an array of numbers'

fn [1 2] # 'an array of numbers'
fn [\a \b] # 'a generic array'
fn {x: 1} # 'default'
```
