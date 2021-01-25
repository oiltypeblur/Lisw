# Lisw

## Overview
Simple lisp library implemented by Swift.

## Requirement
SwiftPM

## Usage

```
git clone ...
cd Lisw
swift build
swift test
```

```
import Lisw

(actual, _) = eval(sexpr: parse(input: "(+ 1 2)"), env: global()) // SExpr.Number(3)
```

## Features

simple

## Reference
http://www.aoky.net/articles/peter_norvig/lispy.htm

## Author
oiltypeblur
