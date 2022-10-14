import XCTest

final class AnyEdgeCaseTests: XCTestCase {
    
    // '(any))'
    // ()
    func test_any_1() throws {
        try verify_program(
            program: "ff2180",
            expected_output: "80"
        )
    }
    
    // '(any (q . 1))'
    // 1
    func test_any_2() throws {
        try verify_program(
            program: "ff21ffff010180",
            expected_output: "01"
        )
    }
    
    // '(any (q . 1) (q . 1))'
    // 1
    func test_any_3() throws {
        try verify_program(
            program: "ff21ffff0101ffff010180",
            expected_output: "01"
        )
    }
    
    // '(any () ())'
    // ()
    func test_any_4() throws {
        try verify_program(
            program: "ff21ff80ff8080",
            expected_output: "80"
        )
    }
    
    // '(any (q . (1 2)) (q . (1 2)))'
    // 1
    func test_any_5() throws {
        try verify_program(
            program: "ff21ffff01ff01ff0280ffff01ff01ff028080",
            expected_output: "01"
        )
    }
    
    // '(any (q . 0xffff) (q . 0xffff))'
    // 1
    func test_any_6() throws {
        try verify_program(
            program: "ff21ffff0182ffffffff0182ffff80",
            expected_output: "01"
        )
    }
    
    // '(any (q . 128) (q . 128))'
    // 1
    func test_any_7() throws {
        try verify_program(
            program: "ff21ffff01820080ffff0182008080",
            expected_output: "01"
        )
    }
    
    // '(any (q . -1) (q . -1))'
    // 1
    func test_any_8() throws {
        try verify_program(
            program: "ff21ffff0181ffffff0181ff80",
            expected_output: "01"
        )
    }


}
