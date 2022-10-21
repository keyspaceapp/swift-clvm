import XCTest

final class LogxorTests: XCTestCase {
    
    // brun -c '(logxor (q . 12) (q . 5))'
    // cost = 685
    // 9
    func test_logxor_1() throws {
        try verify_program(
            program: "ff1affff010cffff010580",
            expected_output: "09",
            expected_cost: 685
        )
    }
    
    // brun -c '(logxor (q . 12) (q . 5) (q . 7))'
    // cost = 972
    // 14
    func test_logxor_2() throws {
        try verify_program(
            program: "ff1affff010cffff0105ffff010780",
            expected_output: "0e",
            expected_cost: 972
        )
    }
    
    // brun -c '(logxor (q . 0x0000000000000000000000000000000000000000000000000000000000000000000000000c) (q . 0x00005) (q . 0x0000000000000000000000000000000000000000000000000000000000000000007))'
    // cost = 1185
    // 14
    func test_logxor_3() throws {
        try verify_program(
            program: "ff1affff01a50000000000000000000000000000000000000000000000000000000000000000000000000cffff0183000005ffff01a20000000000000000000000000000000000000000000000000000000000000000000780",
            expected_output: "0e",
            expected_cost: 1185
        )
    }
    
    // brun -c '(logxor (q . -128) (q . 0x7ffff))'
    // cost = 711
    // 0xf8007f
    func test_logxor_4() throws {
        try verify_program(
            program: "ff1affff018180ffff018307ffff80",
            expected_output: "83f8007f",
            expected_cost: 711
        )
    }
    
}
