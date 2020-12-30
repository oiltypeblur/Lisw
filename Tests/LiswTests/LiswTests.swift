import XCTest
@testable import Lisw

final class LiswTests: XCTestCase {
    func testTokenize(){
        XCTContext.runActivity(named: "number"){ _ in
            let actual = tokenize(input: "10")
            XCTAssertEqual(actual, ["10"])
        }
    }
    
    func testReadFrom(){
        XCTContext.runActivity(named: "number"){_ in
            let actual = readFrom(tokens: ["20"])
            XCTAssertEqual(actual, .Number(20))
        }
    }
    
    func testParse(){
        // var
        XCTContext.runActivity(named: "number"){_ in
            let actual = parse(input:"30")
            XCTAssertEqual(actual, .Number(30))
        }
        // quote
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
