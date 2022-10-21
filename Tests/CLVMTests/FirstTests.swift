import XCTest

final class FirstTests: XCTestCase {
    
    // brun -c '(f (q . (100)))'
    // cost = 51
    // 100
    func test_first_1() throws {
        try verify_program(
            program: "ff05ffff01ff648080",
            expected_output: "64",
            expected_cost: 51
        )
    }
    
    // brun -c '(f (q . (1 2 3)))'
    // cost = 51
    // 1
    func test_first_2() throws {
        try verify_program(
            program: "ff05ffff01ff01ff02ff038080",
            expected_output: "01",
            expected_cost: 51
        )
    }
    
    // brun -c '(f (q . ()))'
    // FAIL: first of non-cons ()
    func test_first_3() throws {
        try verify_throwing_program(
            program: "ff05ffff018080",
            expected_output: "first of non-cons"
        )
    }
    
    // brun -c '(f (f (q . ((100 200 300) 400 500))))'
    // cost = 82
    // 100
    func test_first_4() throws {
        try verify_program(
            program: "ff05ffff05ffff01ffff64ff8200c8ff82012c80ff820190ff8201f4808080",
            expected_output: "64",
            expected_cost: 82
        )
    }

}
