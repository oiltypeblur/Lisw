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
    tmp = tmp.trimmingCharacters(in: .whitespaces)
    return tmp.components(separatedBy: " ")
}

func readFrom(tokens:[String], startIndex: Int)->SExpr{
    precondition(!tokens.isEmpty)
    
    switch tokens[startIndex] {
    case "(":
        var stack = [SExpr]()
        var index = startIndex + 1
        while tokens[index] != ")" {
            stack.append(readFrom(tokens: tokens, startIndex: index))
            index += 1
        }
        return .List(stack)
    default:
        return atom(token:tokens[startIndex])
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
    return readFrom(tokens: tokenize(input: input), startIndex:0)
}
