import XCTest

final class DivEdgeCaseTests: XCTestCase {
    
    // '(/)'
    // / takes exactly 2 arguments ()
    func test_div_1() throws {
        try verify_throwing_program(
            program: "ff1380",
            expected_output: "/ takes exactly 2 arguments"
        )
    }
    
    // '(/ (q . 1))'
    // / takes exactly 2 arguments (q)
    func test_div_2() throws {
        try verify_throwing_program(
            program: "ff13ffff010180",
            expected_output: "/ takes exactly 2 arguments"
        )
    }
    
    // '(/ (q . 1) (q . 1))'
    // 1
    func test_div_3() throws {
        try verify_program(
            program: "ff13ffff0101ffff010180",
            expected_output: "01"
        )
    }
    
    // '(/ (q . 1) (q . 1) (q . 1))'
    // / takes exactly 2 arguments (1 1 1)
    func test_div_4() throws {
        try verify_throwing_program(
            program: "ff13ffff0101ffff0101ffff010180",
            expected_output: "/ takes exactly 2 arguments"
        )
    }
    
    // '(/ () ())'
    // div with 0 ()
    func test_div_5() throws {
        try verify_throwing_program(
            program: "ff13ff80ff8080",
            expected_output: "div with 0"
        )
    }
    
    // '(/ (q . (1 2)) (q . (1 2)))'
    // / requires int args (1 2)
    func test_div_6() throws {
        try verify_throwing_program(
            program: "ff13ffff01ff01ff0280ffff01ff01ff028080",
            expected_output: "/ requires int args"
        )
    }
    
    // '(/ (q . 0xffff) (q . 0xffff))'
    // 1
    func test_div_7() throws {
        try verify_program(
            program: "ff13ffff0182ffffffff0182ffff80",
            expected_output: "01"
        )
    }
    
    // '(/ (q . 128) (q . 128))'
    // 1
    func test_div_8() throws {
        try verify_program(
            program: "ff13ffff01820080ffff0182008080",
            expected_output: "01"
        )
    }
    
    // '(/ (q . -1) (q . -1))'
    // 1
    func test_div_9() throws {
        try verify_program(
            program: "ff13ffff0181ffffff0181ff80",
            expected_output: "01"
        )
    }

}
