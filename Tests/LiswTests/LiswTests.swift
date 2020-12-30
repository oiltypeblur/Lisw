import XCTest
@testable import Lisw

final class LiswTests: XCTestCase {
    func testTokenize(){
        // var
        XCTContext.runActivity(named: "number"){ _ in
            let actual = tokenize(input: "10")
            XCTAssertEqual(actual, "10")
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
