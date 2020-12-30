import Foundation
struct Lisw {
    var text = "Hello, World!"
}

enum SExpr : Equatable {
    case Symbol(String)
    case Number(Double)
    case List([SExpr])
}

func tokenize(input:String)->[String]{
    var tmp = input.replacingOccurrences(of: "(", with: " ( ")
    tmp = tmp.replacingOccurrences(of: ")", with: " ) ")
    tmp = tmp.replacingOccurrences(of: "  ", with: " ")
    tmp = tmp.trimmingCharacters(in: .whitespaces)
    return tmp.components(separatedBy: " ")
}

func readFrom(tokens:[String], startIndex: Int)->(s:SExpr, index:Int){
    //print("readFrom(\(tokens), \(startIndex))")
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

class Environment{}

func eval(sexpr:SExpr, env:Environment)->SExpr{
    return .Number(50)
}
