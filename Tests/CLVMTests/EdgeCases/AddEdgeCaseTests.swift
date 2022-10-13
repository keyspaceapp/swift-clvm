import XCTest

final class AddEdgeCaseTests: XCTestCase {
    
    // '(add)'
    // ()
    func test_add_1() throws {
        try verify_program(
            program: "ff1080",
            expected_output: "80"
        )
    }
    
    // '(+ (q . 1))'
    // 1
    func test_add_2() throws {
        try verify_program(
            program: "ff10ffff010180",
            expected_output: "01"
        )
    }
    
    // '(+ (q . 1) (q . 1))'
    // 1
    func test_add_3() throws {
        try verify_program(
            program: "ff10ffff0101ffff010180",
            expected_output: "02"
        )
    }
    
    // '(+ () ())'
    // ()
    func test_add_4() throws {
        try verify_program(
            program: "ff10ff80ff8080",
            expected_output: "80"
        )
    }
    
    // '(+ (q . (1 2)) (q . (1 2)))'
    // FAIL: + requires int args (1 2)
    func test_add_5() throws {
        try verify_throwing_program(
            program: "ff10ffff01ff01ff0280ffff01ff01ff028080",
            expected_message: "+ requires int args"
        )
    }
    
    // '(+ (q . 0xffff) (q . 0xffff))'
    // -2
    func test_add_6() throws {
        try verify_program(
            program: "ff10ffff0182ffffffff0182ffff80ff10ffff0182ffffffff0182ffff80",
            expected_output: "81fe"
        )
    }
    
    // brun '(+ (q . 128) (q . 128))'
    // 256
    func test_add_7() throws {
        try verify_program(
            program: "ff10ffff01820080ffff0182008080",
            expected_output: "820100"
        )
    }
    
    // brun '(+ (q . -1) (q . -1))'
    // -2
    func test_add_8() throws {
        try verify_program(
            program: "ff10ffff0181ffffff0181ff80",
            expected_output: "81fe"
        )
    }

}
