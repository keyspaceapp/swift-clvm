import XCTest

final class AllTests: XCTestCase {

    // brun -c '(all (q . 1))'
    // cost = 521
    // 1
    func test_all_1() throws {
        try verify_program(
            program: "ff22ffff010180",
            expected_output: "01",
            expected_cost: 521
        )
    }
    
    // brun -c '(all (q . 1) (q . (foo)))'
    // cost = 841
    // 1
    func test_all_2() throws {
        try verify_program(
            program: "ff22ffff0101ffff01ff83666f6f8080",
            expected_output: "01",
            expected_cost: 841
        )
    }
    
    // brun -c '(all (q . 1) (q . 1) (q . 0))'
    // cost = 1161
    // ()
    func test_add_3() throws {
        try verify_program(
            program: "ff22ffff0101ffff0101ffff018080",
            expected_output: "80",
            expected_cost: 1161
        )
    }

}
