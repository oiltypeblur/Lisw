import XCTest
@testable import Lisw

final class LiswTests: XCTestCase {
    func testTokenize(){
        let actual = tokenize(input:"1")
        XCTAssertEqual(actual, "1")
    }

//    static var allTests = [
//        ("testExample", testExample),
//    ]
}
