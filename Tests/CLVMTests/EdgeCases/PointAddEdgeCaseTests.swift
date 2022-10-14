import XCTest

final class PointAddEdgeCaseTests: XCTestCase {
    
    // brun '(point_add)'
    // 0xc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    func test_point_add_1() throws {
        try verify_program(
            program: "ff1d80",
            expected_output: "b0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        )
    }
    
    // brun '(point_add (q . 1))'
    // FAIL: point_add expects blob, got 01: Length of bytes object not equal to G1Element::SIZE (q)
    func test_point_add_2() throws {
        try verify_throwing_program(
            program: "ff1dffff010180",
            expected_output: "point_add expects blob, got 01: Length of bytes object not equal to G1Element::SIZE"
        )
    }
    
    // brun -n '(point_add (q . 1) (q . 1))'
    // FAIL: point_add expects blob, got 01: Length of bytes object not equal to G1Element::SIZE (1 1)
    func test_point_add_3() throws {
        try verify_throwing_program(
            program: "ff1dffff010180",
            expected_output: "point_add expects blob, got 01: Length of bytes object not equal to G1Element::SIZE"
        )
    }
    
    // brun '(point_add () ())'
    // FAIL: point_add expects blob, got 80: Length of bytes object not equal to G1Element::SIZE (() ())
    func test_point_add_4() throws {
        try verify_throwing_program(
            program: "ff1dff80ff8080",
            expected_output: "point_add expects blob, got 80: Length of bytes object not equal to G1Element::SIZE"
        )
    }
    
    // brun -n '(point_add (q . (1 2)) (q . (1 2)))'
    // FAIL: point_add on list (1 2)
    func test_point_add_5() throws {
        try verify_throwing_program(
            program: "ff1dffff01ff01ff0280ffff01ff01ff028080",
            expected_output: "point_add on list"
        )
    }
    
    // brun '(point_add (q . 0xffff) (q . 0xffff))'
    // FAIL: point_add expects blob, got 82ffff: Length of bytes object not equal to G1Element::SIZE (0xffff 0xffff)
    func test_point_add_6() throws {
        try verify_throwing_program(
            program: "ff1dffff0182ffffffff0182ffff80",
            expected_output: "point_add expects blob, got 82ffff: Length of bytes object not equal to G1Element::SIZE"
        )
    }
    
    // brun '(point_add (q . 128) (q . 128))'
    // FAIL: point_add expects blob, got 820080: Length of bytes object not equal to G1Element::SIZE (128 128)
    func test_point_add_8() throws {
        try verify_throwing_program(
            program: "ff1dffff01820080ffff0182008080",
            expected_output: "point_add expects blob, got 820080: Length of bytes object not equal to G1Element::SIZE"
        )
    }
    
    // brun '(point_add (q . -1) (q . -1))'
    // FAIL: point_add expects blob, got 81ff: Length of bytes object not equal to G1Element::SIZE (-1 -1)
    func test_point_add_9() throws {
        try verify_throwing_program(
            program: "ff1dffff0181ffffff0181ff80",
            expected_output: "point_add expects blob, got 81ff: Length of bytes object not equal to G1Element::SIZE"
        )
    }

}
