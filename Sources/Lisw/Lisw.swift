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
    return .Number(20)
}
