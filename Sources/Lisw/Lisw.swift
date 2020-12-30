struct Lisw {
    var text = "Hello, World!"
}

enum SExpr : Equatable {
    case Number(Double)
}

func tokenize(input:String)->[String]{
    return [input]
}

func readFrom(tokens:[String])->SExpr{
    return .Number(Double(tokens[0])!)
}

func parse(input:String)->SExpr{
    return readFrom(tokens: tokenize(input: input))
}
