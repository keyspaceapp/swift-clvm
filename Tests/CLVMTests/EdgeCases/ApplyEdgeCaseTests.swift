import XCTest

final class ApplyEdgeCaseTests: XCTestCase {
    
    // -n '(a)'
    // apply requires exactly 2 parameters (1)
    func test_apply_1() throws {
        try verify_throwing_program(
            program: "ff0280",
            expected_output: "apply requires exactly 2 parameters"
        )
    }
    
    // -n '(a (q . 1))'
    // apply requires exactly 2 parameters (1)
    func test_apply_2() throws {
        try verify_throwing_program(
            program: "ff02ffff010180",
            expected_output: "apply requires exactly 2 parameters"
        )
    }
    
    // --strict '(a (q . 1) (q . 1))'
    // 1
    func test_apply_3() throws {
        try verify_program(
            program: "ff02ffff0101ffff010180",
            expected_output: "01"
        )
    }
    
    // -n '(a (q . 1) (q . 1) (q . 1))'
    // apply requires exactly 2 parameters (1 1 1)
    func test_apply_4() throws {
        try verify_throwing_program(
            program: "ff02ffff0101ffff0101ffff010180",
            expected_output: "apply requires exactly 2 parameters"
        )
    }
    
    // -n '(a (q . 1) (q . 1) (q . 1) (q . 1))'
    // apply requires exactly 2 parameters (1 1 1 1)
    func test_apply_5() throws {
        try verify_throwing_program(
            program: "ff02ffff0101ffff0101ffff0101ffff010180",
            expected_output: "apply requires exactly 2 parameters"
        )
    }
    
    // '(a () () ())'
    // apply requires exactly 2 parameters (() () ())
    func test_apply_6() throws {
        try verify_throwing_program(
            program: "ff02ff80ff80ff8080",
            expected_output: "apply requires exactly 2 parameters"
        )
    }
    
    // -n '(a (q . (1 2)) (q . (1 2)) (q . (1 2)))'
    // apply requires exactly 2 parameters ((1 2) (1 2) (1 2))
    func test_apply_7() throws {
        try verify_throwing_program(
            program: "ff02ffff01ff01ff0280ffff01ff01ff0280ffff01ff01ff028080",
            expected_output: "apply requires exactly 2 parameters"
        )
    }
    
    // '(a (q . 0xffff) (q . 0xffff) (q . 0xffff))'
    // apply requires exactly 2 parameters (0xffff 0xffff 0xffff)
    func test_apply_8() throws {
        try verify_throwing_program(
            program: "ff02ffff0182ffffffff0182ffffffff0182ffff80",
            expected_output: "apply requires exactly 2 parameters"
        )
    }
    
    // '(a (q . 128) (q . 128) (q . 128))'
    // apply requires exactly 2 parameters (128 128 128)
    func test_apply_9() throws {
        try verify_throwing_program(
            program: "ff02ffff01820080ffff01820080ffff0182008080",
            expected_output: "apply requires exactly 2 parameters"
        )
    }
    
    // '(a (q . -1) (q . -1) (q . -1))'
    // apply requires exactly 2 parameters (-1 -1 -1)
    func test_apply_10() throws {
        try verify_throwing_program(
            program: "ff02ffff0181ffffff0181ffffff0181ff80",
            expected_output: "apply requires exactly 2 parameters"
        )
    }

}
