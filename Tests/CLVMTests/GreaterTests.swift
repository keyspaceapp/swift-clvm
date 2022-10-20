import XCTest

final class GreaterTests: XCTestCase {
    
    // brun -n -c '(> (q . 10))'
    // FAIL: > takes exactly 2 arguments (10)
    func test_greater_1() throws {
        try verify_throwing_program(
            program: "ff15ffff010a80",
            expected_output: "> takes exactly 2 arguments"
        )
    }
    
    // brun -c '(> (q . 11) 1)' '10'
    // cost = 567
    // 1
    func test_greater_2() throws {
        try verify_program(
            program: "ff15ffff010bff0180",
            args: "0a",
            expected_output: "01",
            expected_cost: 567
        )
    }
    
    // brun -c '(> (q . 9) 1)' '10'
    // cost = 567
    // ()
    func test_greater_3() throws {
        try verify_program(
            program: "ff15ffff0109ff0180",
            args: "0a",
            expected_output: "80",
            expected_cost: 567
        )
    }
    
    // brun -c '(> (q . 0) (q . 0))'
    // cost = 539
    // ()
    func test_greater_4() throws {
        try verify_program(
            program: "ff15ffff0180ffff018080",
            expected_output: "80",
            expected_cost: 539
        )
    }
    
    // brun -c '(> (q . (0)) (q . 0))'
    // FAIL: > requires int args (())
    func test_greater_5() throws {
        try verify_throwing_program(
            program: "ff15ffff01ff8080ffff018080",
            expected_output: "> requires int args"
        )
    }
    
    // brun -c "(> 3 3)"
    // FAIL: path into atom ()
    func test_greater_6() throws {
        try verify_throwing_program(
            program: "ff15ff03ff0380",
            expected_output: "path into atom"
        )
    }
    
    // brun -c "(> (q . 3) (q . 300))"
    // cost = 545
    // ()
    func test_greater_7() throws {
        try verify_program(
            program: "ff15ffff0103ffff0182012c80",
            expected_output: "80",
            expected_cost: 545
        )
    }
    
    // brun -c "(> (q . 0x5a) (q . 0x493e0))"
    // cost = 547
    // ()
    func test_greater_8() throws {
        try verify_program(
            program: "ff15ffff015affff01830493e080",
            expected_output: "80",
            expected_cost: 547
        )
    }
    
    // brun -c "(> (q . 0x493e0) (q . 0x5a))"
    // cost = 547
    // 1
    func test_greater_9() throws {
        try verify_program(
            program: "ff15ffff01830493e0ffff015a80",
            expected_output: "01",
            expected_cost: 547
        )
    }
}
