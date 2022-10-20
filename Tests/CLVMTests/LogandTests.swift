import XCTest

final class LogandTests: XCTestCase {
    
    // brun -c '(logand (q . 0xfffe) (q . 93))'
    // cost = 688
    // 92
    func test_logand_1() throws {
        try verify_program(
            program: "ff18ffff0182fffeffff015d80",
            expected_output: "5c",
            expected_cost: 688
        )
    }
    
    // brun -c '(logand (q . 13) (q . 12))'
    // cost = 685
    // 12
    func test_logand_2() throws {
        try verify_program(
            program: "ff18ffff010dffff010c80",
            expected_output: "0c",
            expected_cost: 685
        )
    }
    
    // brun -c '(logand (q . 13) (q . 12) (q . 4))'
    // cost = 972
    // 4
    func test_logand_3() throws {
        try verify_program(
            program: "ff18ffff010dffff010cffff010480",
            expected_output: "04",
            expected_cost: 972
        )
    }
    
    // brun -c '(logand)'
    // cost = 111
    // -1
    func test_logand_4() throws {
        try verify_program(
            program: "ff1880",
            expected_output: "81ff",
            expected_cost: 111
        )
    }
    
    // brun -c '(logand (q . 0x000000000000000000000000000000000000000000000000000000000000fffe) (q . 0x00000000000000000000000000000000000000000000000000000000000005D))'
    // cost = 871
    // 92
    func test_logand_5() throws {
        try verify_program(
            program: "ff18ffff01a0000000000000000000000000000000000000000000000000000000000000fffeffff01a0000000000000000000000000000000000000000000000000000000000000005d80",
            expected_output: "5c",
            expected_cost: 871
        )
    }
    
    // brun -c '(logand (q . -128) (q . 0x7ffff))'
    // cost = 711
    // 0x07ff80
    func test_logand_6() throws {
        try verify_program(
            program: "ff18ffff018180ffff018307ffff80",
            expected_output: "8307ff80",
            expected_cost: 711
        )
    }
}
