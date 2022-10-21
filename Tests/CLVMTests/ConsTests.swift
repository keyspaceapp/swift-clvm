import XCTest

final class ConsTests: XCTestCase {
    
    // brun -c '(c)'
    // FAIL: c takes exactly 2 arguments ()
    func test_cons_1() throws {
        try verify_throwing_program(
            program: "ff0480",
            expected_output: "c takes exactly 2 arguments"
        )
    }
    
    // brun -c '(c (q . 100) (q . ()))'
    // cost = 91
    // (100)
    func test_cons_2() throws {
        try verify_program(
            program: "ff04ffff0164ffff018080",
            expected_output: "ff6480",
            expected_cost: 91
        )
    }
    
    // brun -c '(c (q . 100) (q . (200 300 400)))'
    // cost = 91
    // (100 200 300 400)
    func test_cons_3() throws {
        try verify_program(
            program: "ff04ffff0164ffff01ff8200c8ff82012cff8201908080",
            expected_output: "ff64ff8200c8ff82012cff82019080",
            expected_cost: 91
        )
    }
    
    // brun -c '(c (q . 100) (q . ((500 (200 300 400)))))'
    // cost = 91
    // (100 (500 (200 300 400)))
    func test_cons_4() throws {
        try verify_program(
            program: "ff04ffff0164ffff01ffff8201f4ffff8200c8ff82012cff82019080808080",
            expected_output: "ff64ffff8201f4ffff8200c8ff82012cff820190808080",
            expected_cost: 91
        )
    }
    
    // brun -c '(c (q . 100))'
    // FAIL: c takes exactly 2 arguments (100)
    func test_cons_5() throws {
        try verify_throwing_program(
            program: "ff04ffff016480",
            expected_output: "c takes exactly 2 arguments"
        )
    }
    
    // brun -c '((c (q . (+ (q . 50) 1)) (q . 500)))'
    // FAIL: in ((X)...) syntax X must be lone atom ((c (q 16 (q . 50) 1) (q . 500)))
    func test_cons_as_op() throws {
        try verify_throwing_program(
            program: "ffff04ffff01ff10ffff0132ff0180ffff018201f48080",
            expected_output: "in ((X)...) syntax X must be lone atom"
        )
    }

}
