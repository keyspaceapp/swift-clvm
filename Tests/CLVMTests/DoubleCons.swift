import XCTest

final class DoubleConsTests: XCTestCase {
    
    // brun -c '((+) 1 2 3 4)'
    // cost = 1491
    // 10
    func test_double_cons_1() throws {
        try verify_program(
            program: "ffff1080ff01ff02ff03ff0480",
            expected_output: "0a",
            expected_cost: 1491
        )
    }
    
    // brun -c '((*) 1 2 3 4)'
    // cost = 2883
    // 24
    func test_double_cons_2() throws {
        try verify_program(
            program: "ffff1280ff01ff02ff03ff0480",
            expected_output: "18",
            expected_cost: 2883
        )
    }
    
    // brun -c '((+ . foo) 1 2 3)'
    // FAIL: in ((X)...) syntax X must be lone atom ((+ . "foo") 1 2 3)
    func test_double_cons_3() throws {
        try verify_throwing_program(
            program: "ffff1083666f6fff01ff02ff0380",
            expected_output: "in ((X)...) syntax X must be lone atom"
        )
    }
    
    // brun -c '(((+)) 1 2 3)'
    // FAIL: in ((X)...) syntax X must be lone atom (((+)) 1 2 3)
    func test_double_cons_4() throws {
        try verify_throwing_program(
            program: "ffffff108080ff01ff02ff0380",
            expected_output: "in ((X)...) syntax X must be lone atom"
        )
    }

}
