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
            let actual = readFrom(tokens: ["20"], startIndex:0)
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
        // quote
        XCTContext.runActivity(named: "quote"){ _ in
            let actual = parse(input:"(quote 40)")
            XCTAssertEqual(actual, .List([.Symbol("quote"), .Number(40)]))
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
