import XCTest
@testable import Lisw

final class LiswTests: XCTestCase {
    func testTokenize(){
        // var
        XCTContext.runActivity(named: "number"){ _ in
            let actual = tokenize(input: "10")
            XCTAssertEqual(actual, ["10"])
        }
        // quote
        // if
        // set!
        // define
        // lambda
        // begin
        // proc
    }
    
    func testReadFrom(){
        // var
        XCTContext.runActivity(named: "number"){_ in
            let actual = readFrom(tokens: ["20"])
            XCTAssertEqual(actual, .Number(20))
        }
    }

//    static var allTests = [
//        ("testExample", testExample),
//    ]
}
