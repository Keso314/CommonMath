import XCTest
@testable import CommonMath

final class CommonMathTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CommonMath().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
