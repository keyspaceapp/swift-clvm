import XCTest

final class SubTests: XCTestCase {
    
    // brun -c '(- (q . 7) (q . 1))'
    // cost = 796
    // 6
    func test_sub_1() throws {
        try verify_program(
            program: "ff11ffff0107ffff010180",
            expected_output: "06",
            expected_cost: 796
        )
    }
    
    // brun -c '(- (q . 1))'
    // cost = 453
    // 1
    func test_strlen_2() throws {
        try verify_program(
            program: "ff11ffff010180",
            expected_output: "01",
            expected_cost: 453
        )
    }
    
    // brun -c '(- ())'
    // cost = 464
    // ()
    func test_strlen_3() throws {
        try verify_program(
            program: "ff11ff8080",
            expected_output: "80",
            expected_cost: 464
        )
    }
    
    // brun -c '(-)'
    // cost = 100
    // ()
    func test_strlen_4() throws {
        try verify_program(
            program: "ff1180",
            expected_output: "80",
            expected_cost: 100
        )
    }
    
    // brun -c '(- (q . 0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007) (q . 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001))'
    // cost = 1135
    // 6
    func test_strlen_5() throws {
        try verify_program(
            program: "ff11ffff01ba00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007ffff01b900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000180",
            expected_output: "06",
            expected_cost: 1135
        )
    }
    
}
