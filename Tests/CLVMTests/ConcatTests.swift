import XCTest

final class ConcatTests: XCTestCase {
    
    // brun -c '(concat)'
    // cost = 143
    // ()
    func test_concat_1() throws {
        try verify_program(
            program: "ff0e80",
            expected_output: "80",
            expected_cost: 143
        )
    }
    
    // brun -c '(concat (q . foo))'
    // cost = 337
    // "foo"
    func test_concat_2() throws {
        try verify_program(
            program: "ff0effff0183666f6f80",
            expected_output: "83666f6f",
            expected_cost: 337
        )
    }
    
    // brun -c '(concat (q . foo) (q . bar))'
    // cost = 531
    // "foobar"
    func test_concat_3() throws {
        try verify_program(
            program: "ff0effff0183666f6fffff018362617280",
            expected_output: "86666f6f626172",
            expected_cost: 531
        )
    }
    
    // brun -c '(concat (q . foo) (q . (bar)))'
    // FAIL: concat on list ("bar")
    func test_concat_4() throws {
        try verify_throwing_program(
            program: "ff0effff0183666f6fffff01ff836261728080",
            expected_output: "concat on list"
        )
    }

}
