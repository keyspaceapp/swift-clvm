import XCTest

final class RaiseTests: XCTestCase {
    
    // brun -c '(x (q . 2000))'
    // FAIL: clvm raise (2000)
    func test_raise_1() throws {
        try verify_throwing_program(
            program: "ff08ffff018207d080",
            expected_output: "clvm raise"
        )
    }
    
    // brun -c '(x (q . (100)) (q . (200)) (q . (300)))'
    // FAIL: clvm raise ((100) (200) (300))
    func test_raise_2() throws {
        try verify_throwing_program(
            program: "ff08ffff01ff6480ffff01ff8200c880ffff01ff82012c8080",
            expected_output: "clvm raise"
        )
    }
    
}
