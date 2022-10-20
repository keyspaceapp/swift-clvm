import XCTest

final class SoftforkTests: XCTestCase {
    
    // brun -c '(softfork (q . 50))'
    // cost = 71
    // ()
    func test_softfork_1() throws {
        try verify_program(
            program: "ff24ffff013280",
            expected_output: "80",
            expected_cost: 71
        )
    }
    
    // brun -c '(softfork (q . 51) (q . (+ 60 50)))'
    // cost = 92
    // ()
    func test_softfork_2() throws {
        try verify_program(
            program: "ff24ffff0133ffff01ff10ff3cff328080",
            expected_output: "80",
            expected_cost: 92
        )
    }
    
    // brun -c '(softfork (q . 3121) (q . (+ 60 50)))'
    // cost = 3162
    // ()
    func test_softfork_3() throws {
        try verify_program(
            program: "ff24ffff01820c31ffff01ff10ff3cff328080",
            expected_output: "80",
            expected_cost: 3162
        )
    }
    
    // brun -c '(softfork (q . 0) (q . (+ 60 50)))'
    // FAIL: cost must be > 0 (() (+ 60 50))
    func test_softfork_4() throws {
        try verify_throwing_program(
            program: "ff24ffff0180ffff01ff10ff3cff328080",
            expected_output: "cost must be > 0"
        )
    }
    
    // brun -c '(softfork (q . 0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000050))'
    // cost = 101
    // ()
    func test_softfork_5() throws {
        try verify_program(
            program: "ff24ffff01ac000000000000000000000000000000000000000000000000000000000000000000000000000000000000005080",
            expected_output: "80",
            expected_cost: 101
        )
    }
    
}
