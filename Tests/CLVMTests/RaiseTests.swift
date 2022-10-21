import XCTest

final class RestTests: XCTestCase {
    
    // brun -c '(r (q . (100)))'
    // cost = 51
    // ()
    func test_rest_1() throws {
        try verify_program(
            program: "ff06ffff01ff648080",
            expected_output: "80",
            expected_cost: 51
        )
    }
    
    // brun -c '(r (q . (100 200 300)))'
    // cost = 51
    // (200 300)
    func test_rest_2() throws {
        try verify_program(
            program: "ff06ffff01ff64ff8200c8ff82012c8080",
            expected_output: "ff8200c8ff82012c80",
            expected_cost: 51
        )
    }
    
    // brun -c '(r (q . ()))'
    // FAIL: rest of non-cons ()
    func test_rest_3() throws {
        try verify_throwing_program(
            program: "ff06ffff018080",
            expected_output: "rest of non-cons"
        )
    }
    
    // brun -c '(r (r (q . ((100 200 300) 400 500))))'
    // cost = 82
    // (500)
    func test_rest_4() throws {
        try verify_program(
            program: "ff06ffff06ffff01ffff64ff8200c8ff82012c80ff820190ff8201f4808080",
            expected_output: "ff8201f480",
            expected_cost: 82
        )
    }
    
}
