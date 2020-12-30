import XCTest
@testable import Lisw

final class LiswTests: XCTestCase {
    func testTokenize(){
        var actual = tokenize(input: "10")
        XCTAssertEqual(actual, ["10"])

        actual = tokenize(input: "(1 2)")
        XCTAssertEqual(actual, ["(", "1", "2", ")"])
    }
    
    func testReadFrom(){
        XCTContext.runActivity(named: "number"){ _ in
            let (actual, _) = readFrom(tokens: ["20"], startIndex:0)
            XCTAssertEqual(actual, .Number(20))
        }
    }
    
    func testParse(){
        XCTContext.runActivity(named: "var"){ _ in
            let actual = parse(input:"x")
            XCTAssertEqual(actual, .Symbol("x"))
        }
        XCTContext.runActivity(named: "number"){ _ in
            let actual = parse(input:"30")
            XCTAssertEqual(actual, .Number(30))
        }
        XCTContext.runActivity(named: "quote"){ _ in
            let actual = parse(input:"(quote 40)")
            XCTAssertEqual(actual, .List([.Symbol("quote"), .Number(40)]))
        }
        XCTContext.runActivity(named: "conditionals"){ _ in
            let actual = parse(input: "(if (< 10 20) 1 2)")
            XCTAssertEqual(actual, .List([.Symbol("if"), .List([.Symbol("<"), .Number(10), .Number(20)]), .Number(1), .Number(2)]))
        }
        // if
        // set!
        // define
        // lambda
        // begin
        // proc
    }

//    static var allTests = [
//        ("testExample", testExample),
//    ]
}
