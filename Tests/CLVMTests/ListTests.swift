import XCTest

final class ListTests: XCTestCase {
    
    // brun -c '(l (q . 100))'
    // cost = 40
    // ()
    func test_list_1() throws {
        try verify_program(
            program: "ff07ffff016480",
            expected_output: "80",
            expected_cost: 40
        )
    }
    
    // brun -c '(l (q . (100)))'
    // cost = 40
    // 1
    func test_list_2() throws {
        try verify_program(
            program: "ff07ffff01ff648080",
            expected_output: "01",
            expected_cost: 40
        )
    }
    
    // brun -c '(l)'
    // FAIL: l takes exactly 1 argument ()
    func test_list_3() throws {
        try verify_throwing_program(
            program: "ff0780",
            expected_output: "l takes exactly 1 argument"
        )
    }
    
    // brun -c '(l (q . 100) (q . 200))'
    // FAIL: l takes exactly 1 argument (100 200)
    func test_list_4() throws {
        try verify_throwing_program(
            program: "ff07ffff0164ffff018200c880",
            expected_output: "l takes exactly 1 argument"
        )
    }
    
    // brun -c '(l 2)' '(50)'
    // cost = 68
    // ()
    func test_list_5() throws {
        try verify_program(
            program: "ff07ff0280",
            args: "ff3280",
            expected_output: "80",
            expected_cost: 68
        )
    }
}
