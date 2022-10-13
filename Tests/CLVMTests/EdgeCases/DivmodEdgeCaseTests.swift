import XCTest

final class DivmodEdgeCaseTests: XCTestCase {
    
    // brun '(divmod)'
    // FAIL: divmod takes exactly 2 arguments ()
    func test_divmod_1() throws {
        try verify_throwing_program(
            program: "ff1480",
            expected_message: "divmod takes exactly 2 arguments"
        )
    }
    
    // '(divmod (q . 1))'
    // FAIL: divmod takes exactly 2 arguments (1)
    func test_divmod_2() throws {
        try verify_throwing_program(
            program: "ff14ffff010180",
            expected_message: "divmod takes exactly 2 arguments"
        )
    }
    
    // '(divmod (q . 1) (q . 1))'
    // (1)
    func test_divmod_3() throws {
        try verify_program(
            program: "ff14ffff0101ffff010180",
            expected_output: "ff0180"
        )
    }
    
    // '(divmod (q . 1) (q . 1) (q . 1))'
    // FAIL: divmod takes exactly 2 arguments (1 1 1)
    func test_divmod_4() throws {
        try verify_throwing_program(
            program: "ff14ffff0101ffff0101ffff010180",
            expected_message: "divmod takes exactly 2 arguments"
        )
    }
    
    // brun '(divmod () ())'
    // FAIL: divmod with 0 ()
    func test_divmod_5() throws {
        try verify_throwing_program(
            program: "ff14ff80ff8080",
            expected_message: "divmod with 0"
        )
    }
    
    // '(divmod (q . (1 2)) (q . (1 2)))'
    // FAIL: divmod requires int args (1 2)
    func test_divmod_6() throws {
        try verify_throwing_program(
            program: "ff14ffff01ff01ff0280ffff01ff01ff028080",
            expected_message: "divmod requires int args"
        )
    }
    
    // '(divmod (q . 0xffff) (q . 0xffff))'
    // (1)
    func test_divmod_7() throws {
        try verify_program(
            program: "ff14ffff0182ffffffff0182ffff80",
            expected_output: "ff0180"
        )
    }
    
    // '(divmod (q . 128) (q . 128))'
    // (1)
    func test_divmod_8() throws {
        try verify_program(
            program: "ff14ffff01820080ffff0182008080",
            expected_output: "ff0180"
        )
    }
    
    // '(divmod (q . -1) (q . -1))'
    // (1)
    func test_divmod_9() throws {
        try verify_program(
            program: "ff14ffff0181ffffff0181ff80",
            expected_output: "ff0180"
        )
    }

}
