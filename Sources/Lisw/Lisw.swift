import Foundation
struct Lisw {
    var text = "Hello, World!"
}

enum SExpr : Equatable {
    case Symbol(String)
    case Number(Double)
    case List([SExpr])
    case None
}

func tokenize(input:String)->[String]{
    var tmp = input.replacingOccurrences(of: "(", with: " ( ")
    tmp = tmp.replacingOccurrences(of: ")", with: " ) ")
    tmp = tmp.replacingOccurrences(of: "  ", with: " ")
    tmp = tmp.trimmingCharacters(in: .whitespaces)
    return tmp.components(separatedBy: " ")
}

func readFrom(tokens:[String], startIndex: Int)->(s:SExpr, index:Int){
    print("readFrom(\(tokens), \(startIndex))")
    precondition(!tokens.isEmpty)
    
    let token = tokens[startIndex]
    print("token:\(token)")
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
    print("atom(\(token))")
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

class Environment {
    var dictionary = [String:SExpr]()
    let outer:Environment?
    
    init(outer:Environment?) {
        self.outer = outer
    }
    
    subscript(key:String)->SExpr{
        get {
            return dictionary[key]!
        }
        set {
            dictionary[key] = newValue
        }
    }
    
    var description:String {
        return dictionary.description
    }
}

func eval(sexpr:SExpr, env:Environment)->(result:SExpr, env:Environment){
    print("eval(\(sexpr), \(env.description))")
    var result:SExpr = .None
    switch sexpr {
    case .Symbol(let symbol):
        return (env[symbol], env)
    case .Number(_):
        return (sexpr, env)
    case let .List(list):
        switch list[0] {
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
            fatalError()
        }
    default:
        fatalError()
    }
}
