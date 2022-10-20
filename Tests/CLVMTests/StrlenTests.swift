import XCTest

final class StrlenTests: XCTestCase {
    
    // brun -c '(strlen 1)' 'foo-bar'
    // cost = 235
    // 7
    func test_strlen_1() throws {
        try verify_program(
            program: "ff0dff0180",
            args: "87666f6f2d626172",
            expected_output: "07",
            expected_cost: 235
        )
    }
    
    // brun -c '(strlen 1)' '(foo-bar)'
    // FAIL: strlen on list ("foo-bar")
    func test_strlen_2() throws {
        try verify_throwing_program(
            program: "ff0dff0180",
            args: "ff87666f6f2d62617280",
            expected_output: "strlen on list"
        )
    }
    
    // brun -c '(strlen 1)' '()'
    // cost = 218
    // ()
    func test_strlen_3() throws {
        try verify_program(
            program: "ff0dff0180",
            args: "80",
            expected_output: "80",
            expected_cost: 218
        )
    }
    
    // brun -c '(strlen 1)' '"the quick brown fox jumps over the lazy dogs"'
    // cost = 272
    // 44
    func test_strlen_4() throws {
        try verify_program(
            program: "ff0dff0180",
            args: "ac74686520717569636b2062726f776e20666f78206a756d7073206f76657220746865206c617a7920646f6773",
            expected_output: "2c",
            expected_cost: 272
        )
    }
    
}
