import XCTest
@testable import Reminder

final class ReminderTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Reminder().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
