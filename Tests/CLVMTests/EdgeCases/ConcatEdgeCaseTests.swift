import XCTest

final class ConcatEdgeCaseTests: XCTestCase {
    
    // '(concat)'
    // ()
    func test_concat_1() throws {
        try verify_program(
            program: "ff0e80",
            expected_output: "80"
        )
    }

    // '(concat (q . 1))'
    // 1
    func test_concat_2() throws {
        try verify_program(
            program: "ff0effff010180",
            expected_output: "01"
        )
    }
    
    // '(concat (q . 1) (q . 1))'
    // 257
    func test_concat_3() throws {
        try verify_program(
            program: "ff0effff0101ffff010180",
            expected_output: "820101"
        )
    }
    
    // '(concat () ())'
    // ()
    func test_concat_4() throws {
        try verify_program(
            program: "ff0eff80ff8080",
            expected_output: "80"
        )
    }
    
    // -n '(concat (q . (1 2)) (q . (1 2)))'
    // concat on list (1 2)
    func test_concat_5() throws {
        try verify_throwing_program(
            program: "ff0effff01ff01ff0280ffff01ff01ff028080",
            expected_message: "concat on list"
        )
    }
    
    // '(concat (q . 0xffff) (q . 0xffff))'
    // 0xffffffff
    func test_concat_6() throws {
        try verify_program(
            program: "ff0effff0182ffffffff0182ffff80",
            expected_output: "84ffffffff"
        )
    }
    
    // '(concat (q . 128) (q . 128))'
    // 0x00800080
    func test_concat_7() throws {
        try verify_program(
            program: "ff0effff01820080ffff0182008080",
            expected_output: "8400800080"
        )
    }
    
    // '(concat (q . -1) (q . -1))'
    // 0xffff
    func test_concat_8() throws {
        try verify_program(
            program: "ff0effff0181ffffff0181ff80",
            expected_output: "82ffff"
        )
    }

    // '(concat () (q . -1))'
    // -1
    func test_concat_9() throws {
        try verify_program(
            program: "ff0eff80ffff0181ff80",
            expected_output: "81ff"
        )
    }

    // '(concat (q . 1) ())'
    // 1
    func test_concat_10() throws {
        try verify_program(
            program: "ff0effff0101ff8080",
            expected_output: "01"
        )
    }

    // -n '(concat (q . (1 2)) (q . 1))'
    // concat on list (1 2)
    func test_concat_11() throws {
        try verify_throwing_program(
            program: "ff0effff01ff01ff0280ffff010180",
            expected_message: "concat on list"
        )
    }

    // -n '(concat (q . 1) (q . (1 2)))'
    // concat on list (1 2)
    func test_concat_12() throws {
        try verify_throwing_program(
            program: "ff0effff0101ffff01ff01ff028080",
            expected_message: "concat on list"
        )
    }

}
