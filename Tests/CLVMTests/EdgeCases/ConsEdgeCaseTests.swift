import XCTest

final class ConsEdgeCaseTests: XCTestCase {
    
    // '(c)'
    // c takes exactly 2 arguments
    func test_cons_1() throws {
        try verify_throwing_program(
            program: "ff0480",
            expected_output: "c takes exactly 2 arguments"
        )
    }
    
    // '(c (q . 1))'
    // c takes exactly 2 arguments
    func test_cons_2() throws {
        try verify_throwing_program(
            program: "ff04ffff010180",
            expected_output: "c takes exactly 2 arguments"
        )
    }
    
    // '(c (q . 1) (q . 1))'
    // (1 . 1)
    func test_cons_3() throws {
        try verify_program(
            program: "ff04ffff0101ffff010180",
            expected_output: "ff0101"
        )
    }
    
    // '(c (q . 1) (q . 1) (q . 1))'
    // c takes exactly 2 arguments
    func test_cons_4() throws {
        try verify_throwing_program(
            program: "ff04ffff0101ffff0101ffff010180",
            expected_output: "c takes exactly 2 arguments"
        )
    }
    
    // brun '(c () ())'
    // (())
    func test_cons_5() throws {
        try verify_program(
            program: "ff04ff80ff8080",
            expected_output: "ff8080"
        )
    }
    
    // '(c (q . (1 2)) (q . (1 2)))'
    // ((1 2) 1 2)
    func test_cons_6() throws {
        try verify_program(
            program: "ff04ffff01ff01ff0280ffff01ff01ff028080",
            expected_output: "ffff01ff0280ff01ff0280"
        )
    }
    
    // brun '(c (q . 0xffff) (q . 0xffff))'
    // (0xffff . 0xffff)
    func test_cons_7() throws {
        try verify_program(
            program: "ff04ffff0182ffffffff0182ffff80",
            expected_output: "ff82ffff82ffff"
        )
    }
    
    // brun '(c (q . 128) (q . 128))'
    // (128 . 128)
    func test_cons_8() throws {
        try verify_program(
            program: "ff04ffff01820080ffff0182008080",
            expected_output: "ff820080820080"
        )
    }
    
    // brun '(c (q . -1) (q . -1))'
    // (-1 . -1)
    func test_cons_9() throws {
        try verify_program(
            program: "ff04ffff0181ffffff0181ff80",
            expected_output: "ff81ff81ff"
        )
    }

}
