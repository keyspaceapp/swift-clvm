import XCTest

final class SubstrEdgeCaseTests: XCTestCase {
    
    // brun '(substr)'
    // FAIL: substr takes exactly 2 or 3 arguments ()
    func test_substr_1() throws {
        try verify_throwing_program(
            program: "ff0c80",
            expected_output: "substr takes exactly 2 or 3 arguments"
        )
    }
    
    // brun '(substr (q . 1))'
    // FAIL: substr takes exactly 2 or 3 arguments (q)
    func test_substr_2() throws {
        try verify_throwing_program(
            program: "ff0cffff010180",
            expected_output: "substr takes exactly 2 or 3 arguments"
        )
    }
    
    // brun '(substr (q . 1))'
    // FAIL: substr takes exactly 2 or 3 arguments (q)
    func test_substr_3() throws {
        try verify_program(
            program: "ff0cffff0101ffff010180",
            expected_output: "80"
        )
    }
    
    // brun '(substr (q . 1) (q . 1) (q . 1))'
    // ()
    func test_substr_4() throws {
        try verify_program(
            program: "ff0cffff0101ffff0101ffff010180",
            expected_output: "80"
        )
    }
    
    // brun -n '(substr (q . 1) (q . 1) (q . 1) (q . 1))'
    // FAIL: substr takes exactly 2 or 3 arguments (1 1 1 1)
    func test_substr_5() throws {
        try verify_throwing_program(
            program: "ff0cffff0101ffff0101ffff0101ffff010180",
            expected_output: "substr takes exactly 2 or 3 arguments"
        )
    }
    
    // brun '(substr () () ())'
    // ()
    func test_substr_6() throws {
        try verify_program(
            program: "ff0cff80ff80ff8080",
            expected_output: "80"
        )
    }
    
    // brun '(substr () () ())'
    // ()
    func test_substr_7() throws {
        try verify_throwing_program(
            program: "ff0cffff01ff01ff0280ffff01ff01ff0280ffff01ff01ff028080",
            expected_output: "substr on list"
        )
    }
    
    // brun '(substr (q . 0xffff) (q . 0xffff) (q . 0xffff))'
    // FAIL: invalid indices for substr (0xffff 0xffff 0xffff)
    func test_substr_8() throws {
        try verify_throwing_program(
            program: "ff0cffff0182ffffffff0182ffffffff0182ffff80",
            expected_output: "invalid indices for substr"
        )
    }
    
    // brun '(substr (q . 128) (q . 128) (q . 128))'
    // FAIL: invalid indices for substr (128 128 128)
    func test_substr_9() throws {
        try verify_throwing_program(
            program: "ff0cffff01820080ffff01820080ffff0182008080",
            expected_output: "invalid indices for substr"
        )
    }
    
    // brun '(substr (q . -1) (q . -1) (q . -1))'
    // FAIL: invalid indices for substr (-1 -1 -1)
    func test_substr_10() throws {
        try verify_throwing_program(
            program: "ff0cffff0181ffffff0181ffffff0181ff80",
            expected_output: "invalid indices for substr"
        )
    }

}
