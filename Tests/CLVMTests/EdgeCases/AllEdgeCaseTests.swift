import XCTest

final class AllEdgeCaseTests: XCTestCase {
    
    // '(all)'
    // 1
    func test_all_1() throws {
        try verify_program(
            program: "ff2280",
            expected_output: "01"
        )
    }
    
    // '(all (q . 1))'
    // 1
    func test_all_2() throws {
        try verify_program(
            program: "ff22ffff010180",
            expected_output: "01"
        )
    }
    
    // '(all (q . 1) (q . 1))'
    // 1
    func test_all_3() throws {
        try verify_program(
            program: "ff22ffff0101ffff010180",
            expected_output: "01"
        )
    }
    
    // '(all () ())'
    // ()
    func test_all_4() throws {
        try verify_program(
            program: "ff22ff80ff8080",
            expected_output: "80"
        )
    }
    
    // '(all (q . (1 2)) (q . (1 2)))'
    // 1
    func test_all_5() throws {
        try verify_program(
            program: "ff22ffff01ff01ff0280ffff01ff01ff028080",
            expected_output: "01"
        )
    }
    
    // '(all (q . 0xffff) (q . 0xffff))'
    // 1
    func test_all_6() throws {
        try verify_program(
            program: "ff22ffff0182ffffffff0182ffff80",
            expected_output: "01"
        )
    }
    
    // '(all (q . 128) (q . 128))'
    // 1
    func test_all_7() throws {
        try verify_program(
            program: "ff22ffff01820080ffff0182008080",
            expected_output: "01"
        )
    }
    
    // '(all (q . -1) (q . -1))'
    // 1
    func test_all_8() throws {
        try verify_program(
            program: "ff22ffff0181ffffff0181ff80",
            expected_output: "01"
        )
    }


}
