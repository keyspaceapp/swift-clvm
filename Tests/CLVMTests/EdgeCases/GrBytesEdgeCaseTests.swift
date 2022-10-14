import XCTest

final class GrBytesEdgeCaseTests: XCTestCase {

    // brun '(>s)'
    // FAIL: >s takes exactly 2 arguments ()
    func test_gr_bytes_1() throws {
        try verify_throwing_program(
            program: "ff0a80",
            expected_output: ">s takes exactly 2 arguments"
        )
    }
    
    // brun -n '(>s (q . 1))'
    // FAIL: >s takes exactly 2 arguments (1)
    func test_gr_bytes_2() throws {
        try verify_throwing_program(
            program: "ff0affff010180",
            expected_output: ">s takes exactly 2 arguments"
        )
    }
    
    // brun '(>s (q . 1) (q . 1))'
    // ()
    func test_gr_bytes_3() throws {
        try verify_program(
            program: "ff0affff0101ffff010180",
            expected_output: "80"
        )
    }
    
    // brun -n '(>s (q . 1) (q . 1) (q . 1))'
    // FAIL: >s takes exactly 2 arguments (1 1 1)
    func test_gr_bytes_4() throws {
        try verify_throwing_program(
            program: "ff0affff0101ffff0101ffff010180",
            expected_output: ">s takes exactly 2 arguments"
        )
    }
    
    // brun '(>s () ())'
    // ()
    func test_gr_bytes_5() throws {
        try verify_program(
            program: "ff0aff80ff8080",
            expected_output: "80"
        )
    }
    
    // brun -n '(>s (q . (1 2)) (q . (1 2)))'
    // FAIL: >s on list (1 2)
    func test_gr_bytes_6() throws {
        try verify_throwing_program(
            program: "ff0affff01ff01ff0280ffff01ff01ff028080",
            expected_output: ">s on list"
        )
    }
    
    // brun '(>s (q . 0xffff) (q . 0xffff))' '(q . (1 2)))'
    // ()
    func test_gr_bytes_7() throws {
        try verify_program(
            program: "ff0affff0182ffffffff0182ffff80",
            expected_output: "80"
        )
    }
    
    // brun '(>s (q . 128) (q . 128))'
    // ()
    func test_gr_bytes_8() throws {
        try verify_program(
            program: "ff0affff01820080ffff0182008080",
            expected_output: "80"
        )
    }
    
    // brun '(>s (q . -1) (q . -1))'
    // ()
    func test_gr_bytes_9() throws {
        try verify_program(
            program: "ff0affff0181ffffff0181ff80",
            expected_output: "80"
        )
    }

}
