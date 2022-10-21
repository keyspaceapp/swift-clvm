import XCTest

final class HexTests: XCTestCase {
    
    // brun -c '(q . 0x00)'
    // cost = 20
    // 0x00
    func test_hex_1() throws {
        try verify_program(
            program: "ff0100",
            expected_output: "00",
            expected_cost: 20
        )
    }
    
    // brun -c '(q . 0x007eff)'
    // cost = 20
    // 0x007eff
    func test_hex_2() throws {
        try verify_program(
            program: "ff0183007eff",
            expected_output: "83007eff",
            expected_cost: 20
        )
    }
}
