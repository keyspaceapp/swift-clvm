import XCTest

final class AnyTests: XCTestCase {

    // brun -c '(any (q . 1))'
    // cost = 521
    // 1
    func test_any_1() throws {
        try verify_program(
            program: "ff21ffff010180",
            expected_output: "01",
            expected_cost: 521
        )
    }
    
    // brun -c '(any (q . 0) (q . (foo)))'
    // cost = 841
    // 1
    func test_any_2() throws {
        try verify_program(
            program: "ff22ffff0101ffff01ff83666f6f8080",
            expected_output: "01",
            expected_cost: 841
        )
    }
    
    // brun -c '(any (q . 0) (q . 0))'
    // cost = 841
    // ()
    func test_any_3() throws {
        try verify_program(
            program: "ff21ffff0180ffff018080",
            expected_output: "80",
            expected_cost: 841
        )
    }

}
