import Foundation
struct Lisw {
    var text = "Hello, World!"
}

enum SExpr : CustomStringConvertible, Equatable {
    static func == (lhs: SExpr, rhs: SExpr) -> Bool {
        switch (lhs, rhs) {
        case let (.Symbol(l), .Symbol(r)):
            return l == r
        case let (.Number(l), .Number(r)):
            return l == r
        case let (.Boolean(l), .Boolean(r)):
            return l == r
        case let (.List(l), .List(r)):
            return l == r
        case (.None, .None):
            return true
        default:
            return false
        }
    }

    case Symbol(String)
    case Number(Double)
    case Boolean(Bool)
    case List([SExpr])
    case Procedure(([SExpr]) -> SExpr)
    case None
    
    var description: String {
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
        case .None:
            return "None"
        }
    }
}

func tokenize(input:String)->[String]{
    var tmp = input.replacingOccurrences(of: "(", with: " ( ")
    tmp = tmp.replacingOccurrences(of: ")", with: " ) ")
    // TODO bad
    tmp = tmp.replacingOccurrences(of: "  ", with: " ")
    tmp = tmp.replacingOccurrences(of: "  ", with: " ")
    tmp = tmp.trimmingCharacters(in: .whitespaces)
    return tmp.components(separatedBy: " ")
}

func readFrom(tokens:[String], startIndex: Int)->(s:SExpr, index:Int){
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
        return (atom(token:token), startIndex + 1)
    }
}

func atom(token:String)->SExpr{
    if let num = Double(token) {
        return .Number(num)
    } else {
        return .Symbol(token)
    }
}

func parse(input:String)->SExpr{
    let (s, _) = readFrom(tokens: tokenize(input: input), startIndex:0)
    return s
}

class Environment : CustomStringConvertible {
    var dictionary = [String:SExpr]()
    let outer:Environment?
    
    init(outer:Environment?) {
        self.outer = outer
    }
    
    subscript(key:String)->SExpr{
        get {
            if let value = dictionary[key] {
                return value
            } else {
                debugPrint("\(key) is not registered")
                return .None
            }
        }
        set {
            dictionary[key] = newValue
        }
    }
    
    var description:String {
        return dictionary.description
    }
}

func plus(args:[SExpr]) -> SExpr {
    var result:Double = 0
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

func lessThan(args:[SExpr]) -> SExpr {
    switch (args[0], args[1]) {
    case let (.Number(left), .Number(right)):
        return .Boolean(left < right)
    default:
        fatalError()
    }
}

func global() -> Environment {
    let env = Environment(outer: nil)
    
    env["+"] = .Procedure(plus)
    env["<"] = .Procedure(lessThan)

    return env
}

func eval(sexpr:SExpr, env:Environment)->(result:SExpr, env:Environment){
//    print("eval(\(sexpr), \(env.description))")
    var result:SExpr = .None
    switch sexpr {
    case .Symbol(let symbol):
        return (env[symbol], env)
    case .Number(_):
        return (sexpr, env)
    case let .List(list):
        switch list[0] {
        case .Symbol("quote"):
            return (list[1], env)
        case .Symbol("if"):
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
            let valueName = list[1]
            let newValue = list[2]
            if case let .Symbol(tmp) = valueName {
                if env[tmp] == .None {
                    fatalError()
                }
                env[tmp] = newValue
                return (.None, env)
            } else {
                fatalError()
            }
        case .Symbol("define"):
            var key:String
            var value:SExpr
            switch list[1] {
            case .Symbol(let tmp):
                key = tmp
            default:
                fatalError()
            }
            (value, _) = eval(sexpr:list[2], env: env)
            let newEnv = env
            newEnv[key] = value
            return (.None, newEnv)
        case .Symbol("lambda"):
            let tmp = list[1]
            if case let .List(vars) = tmp {
                let exp = list[2]
                return (.Procedure({(args:[SExpr]) -> SExpr in
                    for index in 0..<vars.count  {
                        if case let .Symbol(key) = vars[index] {
                            env[key] = args[index]
                        } else {
                            fatalError()
                            
                        }
                    }
                    let (result, _) = eval(sexpr: exp, env: env)
                    return result
                }),
                env)
            } else {
                fatalError()
            }
        case .Symbol("begin"):
            var newEnv = env
            for i in 1..<list.count {
                (result, newEnv) = eval(sexpr: list[i], env: env)
            }
            return (result, newEnv)
        default:
            var exps = [SExpr]()
            var newEnv = env
            for l in list {
                var exp:SExpr = .None
                (exp, newEnv) = eval(sexpr: l, env: newEnv)
                exps.append(exp)
            }
            switch exps.first {
            case .Procedure(let f):
                return (f(Array(exps[1...])), newEnv)
            default:
                fatalError()
            }
        }
    default:
        fatalError()
    }
}
