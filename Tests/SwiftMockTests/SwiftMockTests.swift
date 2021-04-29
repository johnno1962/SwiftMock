import XCTest
@testable import SwiftMock
import DLKit

let originalValue = 11
let mockedValue = 22

struct OriginalStruct {
    var v: Int { originalValue }
    func f() -> Int {
        return originalValue
    }
}

struct MockedStruct {
    var v: Int { mockedValue }
    func f() -> Int {
        return mockedValue
    }
}

class OriginalClass {
    var v: Int { originalValue }
    func f() -> Int {
        return originalValue
    }
}

class MockedClass: OriginalClass {
    override var v: Int { mockedValue }
    override func f() -> Int {
        return mockedValue
    }
}

final class SwiftMockTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        guard let myImage = DLKit.imageMap["SwiftMockTests"] else {
            return XCTFail("Could not locate image")
        }

        XCTAssertEqual(OriginalStruct().f(), originalValue)
        XCTAssertEqual(OriginalStruct().v, originalValue)
        SwiftMock.pose(MockedStruct.self, as: OriginalStruct.self,
                       image: myImage)
        XCTAssertEqual(OriginalStruct().f(), mockedValue)
        XCTAssertEqual(OriginalStruct().v, mockedValue)

        XCTAssertEqual(OriginalClass().f(), originalValue)
        XCTAssertEqual(OriginalClass().v, originalValue)
        SwiftMock.pose(MockedClass.self, as: OriginalClass.self,
                       image: myImage)
        XCTAssertEqual(OriginalClass().f(), mockedValue)
        XCTAssertEqual(OriginalClass().v, mockedValue)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
