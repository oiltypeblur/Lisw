import Foundation

/// S-Expression
public enum SExpr {
  case Symbol(String)
  case Number(Double)
  case Boolean(Bool)
  indirect case List([SExpr])
  indirect case Procedure(([SExpr]) -> SExpr)
}

extension SExpr: CustomStringConvertible {
    public var description: String {
    switch self {
    case .Symbol(let s):
      return s
    case .Number(let d):
      return String(d)
    case .Boolean(let b):
      return String(b)
    case .List(let l):
      return l.description
    case .Procedure(_):
      return "func"
    }
  }
}

extension SExpr: Equatable {
    public static func == (lhs: SExpr, rhs: SExpr) -> Bool {
    switch (lhs, rhs) {
    case (let .Symbol(l), let .Symbol(r)):
      return l == r
    case (let .Number(l), let .Number(r)):
      return l == r
    case (let .Boolean(l), let .Boolean(r)):
      return l == r
    case (let .List(l), let .List(r)):
      return l == r
    default:
      return false
    }
  }
}

func tokenize(input: String) -> [String] {
  var tmp = input.replacingOccurrences(of: "(", with: " ( ")
  tmp = tmp.replacingOccurrences(of: ")", with: " ) ")
  // TODO: bad
  tmp = tmp.replacingOccurrences(of: "  ", with: " ")
  tmp = tmp.replacingOccurrences(of: "  ", with: " ")
  tmp = tmp.trimmingCharacters(in: .whitespaces)
  return tmp.components(separatedBy: " ")
}

func readFrom(tokens: [String], startIndex: Int) -> (s: SExpr, index: Int) {
  //    print("readFrom(\(tokens), \(startIndex))")
  precondition(!tokens.isEmpty)

  let token = tokens[startIndex]
  switch token {
  case "(":
    var stack = [SExpr]()
    var index = startIndex + 1
    while tokens[index] != ")" {
      let (s, i) = readFrom(tokens: tokens, startIndex: index)
      stack.append(s)
      index = i
    }
    return (.List(stack), index + 1)
  default:
    return (atom(token: token), startIndex + 1)
  }
}

func atom(token: String) -> SExpr {
  if let num = Double(token) {
    return .Number(num)
  } else {
    return .Symbol(token)
  }
}

func parse(input: String) -> SExpr {
  let (s, _) = readFrom(tokens: tokenize(input: input), startIndex: 0)
  return s
}

/// Environment
public class Environment {
  var dictionary = [String: SExpr]()
  let outer: Environment?

  init(outer: Environment?) {
    self.outer = outer
  }

  subscript(key: String) -> SExpr? {
    get {
      return dictionary[key]
    }
    set {
      dictionary[key] = newValue
    }
  }
}

extension Environment: CustomStringConvertible {
    public var description: String {
    return dictionary.description
  }
}

func plus(args: [SExpr]) -> SExpr {
  var result: Double = 0
  for arg in args {
    switch arg {
    case .Number(let d):
      result += d
    default:
      fatalError()
    }
  }

  return .Number(result)
}

func lessThan(args: [SExpr]) -> SExpr {
  precondition(args.count == 2)

  guard case let .Number(first) = args[0] else {
    fatalError()
  }
  guard case let .Number(second) = args[1] else {
    fatalError()
  }

  return .Boolean(first < second)
}

func global() -> Environment {
  let env = Environment(outer: nil)

  env["+"] = .Procedure(plus)
  env["<"] = .Procedure(lessThan)

  return env
}

/// evaluate S-Expression
/// - Parameters:
///   - sexpr: S-Expression
///   - env: Environment
/// - Returns: evaluated value
public func eval(sexpr: SExpr, env: Environment) -> (result: SExpr?, env: Environment) {
  //    print("eval(\(sexpr), \(env.description))")
  var result: SExpr?

  switch sexpr {
  case .Symbol(let symbol):
    return (env[symbol], env)
  case .Number(_):
    return (sexpr, env)
  case .List(let list):
    switch list[0] {
    case .Symbol("quote"):
      return (list[1], env)
    case .Symbol("if"):
      precondition(list.count == 4)
      let test = list[1]
      let conseq = list[2]
      let alt = list[3]
      let (b, newEnv) = eval(sexpr: test, env: env)
      if b == .Boolean(true) {
        return eval(sexpr: conseq, env: newEnv)
      } else {
        return eval(sexpr: alt, env: newEnv)
      }
    case .Symbol("set!"):
      precondition(list.count == 3)
      guard case let .Symbol(valueName) = list[1] else {
        fatalError()
      }
      if env[valueName] == nil {
        fatalError()
      }
      env[valueName] = list[2]
      return (nil, env)
    case .Symbol("define"):
      precondition(list.count == 3)
      guard case let .Symbol(key) = list[1] else {
        fatalError()
      }
      let (value, newEnv) = eval(sexpr: list[2], env: env)
      newEnv[key] = value
      return (nil, newEnv)
    case .Symbol("lambda"):
      precondition(list.count == 3)
      guard case let .List(vars) = list[1] else {
        fatalError()
      }
      let exp = list[2]
      return (
        .Procedure({ (args: [SExpr]) -> SExpr in
          for index in 0..<vars.count {
            if case let .Symbol(key) = vars[index] {
              env[key] = args[index]
            } else {
              fatalError()
            }
          }
          let (result, _) = eval(sexpr: exp, env: env)
          return result!
        }), env
      )
    case .Symbol("begin"):
      var newEnv = env
      _ = list.map { s in
        (result, newEnv) = eval(sexpr: s, env: newEnv)
      }
      return (result, newEnv)
    default:
      // procedure call
      var newEnv = env
      let exps = list.map { s -> SExpr in
        var exp: SExpr?
        (exp, newEnv) = eval(sexpr: s, env: newEnv)
        return exp!
      }
      guard case let .Procedure(f) = exps.first else {
        fatalError()
      }
      return (f(Array(exps.dropFirst())), newEnv)
    }
  default:
    fatalError()
  }
}
