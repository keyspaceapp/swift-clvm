import XCTest

final class DivTests: XCTestCase {

    // brun -c '(/ 2 5)' '(80001 73)'
    // cost = 1125
    // 1095
    func test_div_1() throws {
        try verify_program(
            program: "ff13ff02ff0580",
            args: "ff83013881ff4980",
            expected_output: "820447",
            expected_cost: 1125
        )
    }
    
    // brun -c '(/ 2 5)' '(-80001 73)'
    // cost = 1125
    // -1096
    func test_div_2() throws {
        try verify_program(
            program: "ff13ff02ff0580",
            args: "ff83fec77fff4980",
            expected_output: "82fbb8",
            expected_cost: 1125
        )
    }
    
    // brun -c '(/ 2 5)' '(80001 -73)'
    // cost = 1125
    // -1096
    func test_div_3() throws {
        try verify_program(
            program: "ff13ff02ff0580",
            args: "ff83013881ff81b780",
            expected_output: "82fbb8",
            expected_cost: 1125
        )
    }
    
    // brun -c '(/ 2 5)' '(80001 0)'
    // FAIL: div with 0 0x013881
    func test_div_4() throws {
        try verify_throwing_program(
            program: "ff13ff02ff0580",
            args: "ff83013881ff8080",
            expected_output: "div with 0"
        )
    }
    
    // brun -c '(/ (q . 0x00000000000000000000000000000000000000000000000000000000a) (q . 0x000000000000000000000000000000000000000000000000000000000000000000000005))'
    // cost = 1299
    // 2
    func test_div_5() throws {
        try verify_program(
            program: "ff13ffff019d000000000000000000000000000000000000000000000000000000000affff01a400000000000000000000000000000000000000000000000000000000000000000000000580",
            expected_output: "02",
            expected_cost: 1299
        )
    }
    
    // brun -c '(/ (q . 3) (q . 10))'
    // cost = 1037
    // ()
    func test_div_6() throws {
        try verify_program(
            program: "ff13ffff0103ffff010a80",
            expected_output: "80",
            expected_cost: 1037
        )
    }
    
    // brun -c '(/ (q . -3) (q . 10))'
    // cost = 1037
    // ()
    func test_div_7() throws {
        try verify_program(
            program: "ff13ffff0181fdffff010a80",
            expected_output: "80",
            expected_cost: 1037
        )
    }
    
    // brun -c '(/ (q . 3) (q . -10))'
    // cost = 1037
    // ()
    func test_div_8() throws {
        try verify_program(
            program: "ff13ffff0103ffff0181f680",
            expected_output: "80",
            expected_cost: 1037
        )
    }
    
    // brun -c '(/ (q . -3) (q . -10))'
    // cost = 1037
    // ()
    func test_div_9() throws {
        try verify_program(
            program: "ff13ffff0181fdffff0181f680",
            expected_output: "80",
            expected_cost: 1037
        )
    }

}
