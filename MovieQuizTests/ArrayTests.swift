import XCTest
@testable import MovieQuiz

class ArayTests: XCTestCase {
    // тест на успешное взятие элемента по индексу
    func testGetValueInRange() throws {
        // Given
        let array = [6, 1, 2, 8, 5]
        
        // When
        let value = array[safe: 2]
        
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    // тест на взятие элемента по неправильному индексу
    func testGetValueOutOfRange() throws {
        // Given
        let array = [6, 1, 2, 8, 5]
        
        // When
        let value = array[safe: 20]
        
        // Then
        XCTAssertNil(value)
    }
}