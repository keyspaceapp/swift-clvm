import XCTest

final class MaxCostTests: XCTestCase {
    
    // brun -c -m 73 '(c (q . 100) (q . 200))'
    // FAIL: cost exceeded 73
    func test_max_cost_1() throws {
        try verify_throwing_program(
            max_cost: 73,
            program: "ff04ffff0164ffff018200c880",
            expected_output: "cost exceeded"
        )
    }
    
    // brun -m 72 '(c (q . 100) (q . 200))'
    // FAIL: cost exceeded 72
    func test_max_cost_2() throws {
        try verify_throwing_program(
            max_cost: 72,
            program: "ff04ffff0164ffff018200c880",
            expected_output: "cost exceeded"
        )
    }
    
}
