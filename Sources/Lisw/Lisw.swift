import Foundation
struct Lisw {
    var text = "Hello, World!"
}

enum SExpr : CustomStringConvertible, Equatable {
    static func == (lhs: SExpr, rhs: SExpr) -> Bool {
        // print("==(\(lhs), \(rhs))")
        switch (lhs, rhs) {
        case let (.Symbol(l), .Symbol(r)):
            return l == r
        case let (.Number(l), .Number(r)):
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
    case List([SExpr])
    case Procedure(([SExpr]) -> SExpr)
    case None
    
    var description: String {
        switch self {
        case .Symbol(let s):
            return s
        case .Number(let d):
            return String(d)
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
    tmp = tmp.replacingOccurrences(of: "  ", with: " ")
    tmp = tmp.trimmingCharacters(in: .whitespaces)
    return tmp.components(separatedBy: " ")
}

func readFrom(tokens:[String], startIndex: Int)->(s:SExpr, index:Int){
//    print("readFrom(\(tokens), \(startIndex))")
    precondition(!tokens.isEmpty)
    
    let token = tokens[startIndex]
//    print("token:\(token)")
    switch token {
    case "(":
        var stack = [SExpr]()
        
        var index = startIndex + 1
        while tokens[index] != ")" {
            let (s, i) = readFrom(tokens: tokens, startIndex: index)
            stack.append(s)
//            print("stack:\(stack)")
            index = i
        }
        return (.List(stack), index + 1)
    default:
        return (atom(token:token), startIndex + 1)
    }
}

func atom(token:String)->SExpr{
//    print("atom(\(token))")
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

func global() -> Environment {
    let env = Environment(outer: nil)
    
    env["+"] = .Procedure(plus)

    return env
}

func eval(sexpr:SExpr, env:Environment)->(result:SExpr, env:Environment){
    // print("eval(\(sexpr), \(env.description))")
    var result:SExpr = .None
    switch sexpr {
    case .Symbol(let symbol):
        return (env[symbol], env)
    case .Number(_):
        return (sexpr, env)
    case let .List(list):
        // print("list:\(list)")
        switch list[0] {
        case .Symbol("quote"):
            return (list[1], env)
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
            // print("exps:\(exps)")
            switch exps.first {
            case .Procedure(let f):
                return (f(Array(exps[1..<exps.count])), newEnv)
            default:
                fatalError()
            }
        }
    default:
        fatalError()
    }
}
