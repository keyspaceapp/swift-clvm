import XCTest

final class LogiorTests: XCTestCase {
    
    // brun -c '(logior (q . 12) (q . 5))'
    // cost = 685
    // 13
    func test_logior_1() throws {
        try verify_program(
            program: "ff19ffff010cffff010580",
            expected_output: "0d",
            expected_cost: 685
        )
    }
    
    // brun -c '(logior (q . 12) (q . 5) (q . 7))'
    // cost = 972
    // 15
    func test_logior_2() throws {
        try verify_program(
            program: "ff19ffff010cffff0105ffff010780",
            expected_output: "0f",
            expected_cost: 972
        )
    }
    
    // brun -c '(logior (q . 0x0000000000000000000000000000000000000000000000000000000000000000000000000000c) (q . 0x00005) (q . 0x00000000000000000000000000000000000000000000000000000000000000007))'
    // cost = 1188
    // 15
    func test_logior_3() throws {
        try verify_program(
            program: "ff19ffff01a700000000000000000000000000000000000000000000000000000000000000000000000000000cffff0183000005ffff01a100000000000000000000000000000000000000000000000000000000000000000780",
            expected_output: "0f",
            expected_cost: 1188
        )
    }
    
    // brun -c '(logior (q . -128) (q . 0x7ffff))'
    // cost = 691
    // -1
    func test_logior_4() throws {
        try verify_program(
            program: "ff19ffff018180ffff018307ffff80",
            expected_output: "81ff",
            expected_cost: 691
        )
    }
    
}
