import XCTest
@testable import Lisw

final class LiswTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Lisw().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
