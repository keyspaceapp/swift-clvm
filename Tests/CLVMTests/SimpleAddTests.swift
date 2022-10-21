import XCTest

final class SimpleAddTests: XCTestCase {
    
    // brun -c "(+ (q . 10) (q . 20))"
    // cost = 796
    // 30
    func test_simple_add_1() throws {
        try verify_program(
            program: "ff10ffff010affff011480",
            expected_output: "1e",
            expected_cost: 796
        )
    }
    
}
