import XCTest

final class AddTests: XCTestCase {

    // '(+ (q . 7) (q . 1))'
    // 8
    func test_add_1() throws {
        try verify_program(
            program: "ff10ffff0107ffff010180",
            expected_output: "08",
            expected_cost: 796
        )
    }
    
    // '(+ (q . 1))'
    // 1
    func test_add_2() throws {
        try verify_program(
            program: "ff10ffff010180",
            expected_output: "01",
            expected_cost: 453
        )
    }
    
    // '(+ ())'
    // ()
    func test_add_3() throws {
        try verify_program(
            program: "ff10ff8080",
            expected_output: "80",
            expected_cost: 464
        )
    }
    
    // '(+)'
    // ()
    func test_add_4() throws {
        try verify_program(
            program: "ff1080",
            expected_output: "80",
            expected_cost: 100
        )
    }
    
    // '(+ (q . 0x0000000000000000000000000000000000000000000000000000000000000000000000000000000007) (q . 0x000000000000000000000000000000000000000000000000000000000000000000000001))'
    // 8
    func test_add_5() throws {
         try verify_program(
            program: "ff10ffff01a90000000000000000000000000000000000000000000000000000000000000000000000000000000007ffff01a400000000000000000000000000000000000000000000000000000000000000000000000180",
            expected_output: "08",
            expected_cost: 1021
        )
    }

}
