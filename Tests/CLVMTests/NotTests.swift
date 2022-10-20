import XCTest

final class NotTests: XCTestCase {
    
    // brun -c '(not (q . 0))'
    // cost = 221
    // 1
    func test_not_1() throws {
        try verify_program(
            program: "ff20ffff018080",
            expected_output: "01",
            expected_cost: 221
        )
    }
    
    // brun -c '(not (q . 1))'
    // cost = 221
    // ()
    func test_not_2() throws {
        try verify_program(
            program: "ff20ffff010180",
            expected_output: "80",
            expected_cost: 221
        )
    }
    
    // brun -c '(not (q . (foo bar)))'
    // cost = 221
    // ()
    func test_not_3() throws {
        try verify_program(
            program: "ff20ffff01ff83666f6fff836261728080",
            expected_output: "80",
            expected_cost: 221
        )
    }
    
}
