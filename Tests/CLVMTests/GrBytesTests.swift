import XCTest

final class GrBytesTests: XCTestCase {
    
    // brun -c '(>s (q . 0x00) (q . ""))'
    // cost = 159
    // 1
    func test_gr_bytes_1() throws {
        try verify_program(
            program: "ff0affff0100ffff018080",
            expected_output: "01",
            expected_cost: 159
        )
    }
    
    // brun -c '(>s (q . 0x01) (q . 0x00))'
    // cost = 160
    // 1
    func test_gr_bytes_2() throws {
        try verify_program(
            program: "ff0affff0101ffff010080",
            expected_output: "01",
            expected_cost: 160
        )
    }
    
    // brun -c '(>s (q . 0x00) (q . 0x01))'
    // cost = 160
    // ()
    func test_gr_bytes_3() throws {
        try verify_program(
            program: "ff0affff0100ffff010180",
            expected_output: "80",
            expected_cost: 160
        )
    }
    
    // brun -c '(>s (q . 0x1000) (q . 0x1001))'
    // cost = 162
    // ()
    func test_gr_bytes_4() throws {
        try verify_program(
            program: "ff0affff01821000ffff0182100180",
            expected_output: "80",
            expected_cost: 162
        )
    }
    
    // brun -c '(>s (q . 0x1000) (q . 0x01))'
    // cost = 161
    // 1
    func test_gr_bytes_5() throws {
        try verify_program(
            program: "ff0affff01821000ffff010180",
            expected_output: "01",
            expected_cost: 161
        )
    }
    
    // brun -c '(>s (q . 0x1000) (q . 0x1000))'
    // cost = 162
    // ()
    func test_gr_bytes_6() throws {
        try verify_program(
            program: "ff0affff01821000ffff0182100080",
            expected_output: "80",
            expected_cost: 162
        )
    }
    
    // brun -c '(>s (q . 0x001004) (q . 0x1005))'
    // cost = 163
    // ()
    func test_gr_bytes_7() throws {
        try verify_program(
            program: "ff0affff0183001004ffff0182100580",
            expected_output: "80",
            expected_cost: 163
        )
    }
    
    // brun -c '(>s (q . 0x1005) (q . 0x001004))'
    // cost = 163
    // 1
    func test_gr_bytes_8() throws {
        try verify_program(
            program: "ff0affff01821005ffff018300100480",
            expected_output: "01",
            expected_cost: 163
        )
    }
    
    // brun -c '(>s (q . (100 200)) (q . 0x001004))'
    // FAIL: >s on list (100 200)
    func test_gr_bytes_9() throws {
        try verify_throwing_program(
            program: "ff0affff01ff64ff8200c880ffff018300100480",
            expected_output: ">s on list"
        )
    }

}
