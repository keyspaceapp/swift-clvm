import XCTest

final class EvalTests: XCTestCase {
    
    // brun -c '(a (q . 1) (q . (100 200)))'
    // cost = 175
    // (100 200)
    func test_eval_1() throws {
        try verify_program(
            program: "ff02ffff0101ffff01ff64ff8200c88080",
            expected_output: "ff64ff8200c880",
            expected_cost: 175
        )
    }
    
    // brun -n -c '(a (q . 1))'
    // FAIL: apply requires exactly 2 parameters (1)
    func test_eval_2() throws {
        try verify_throwing_program(
            program: "ff02ffff010180",
            expected_output: "apply requires exactly 2 parameters"
        )
    }
    
    // brun -c '(a (q . (c (f 1) (q . (105 200)))) (q . (100 200)))'
    // cost = 277
    // (100 105 200)
    func test_eval_3() throws {
        try verify_program(
            program: "ff02ffff01ff04ffff05ff0180ffff01ff69ff8200c88080ffff01ff64ff8200c88080",
            expected_output: "ff64ff69ff8200c880",
            expected_cost: 277
        )
    }
    
    // brun -c '(a (q . 0) (q . 1) (q . 2))'
    // FAIL: apply requires exactly 2 parameters (() 1 2)
    func test_eval_4() throws {
        try verify_throwing_program(
            program: "ff02ffff0180ffff0101ffff010280",
            expected_output: "apply requires exactly 2 parameters"
        )
    }

}
