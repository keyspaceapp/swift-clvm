import XCTest

final class UnknownTests: XCTestCase {
    
    // brun -c '(a (q 0x00ffffffffffffffffffff00) (q ()))'
    // FAIL: invalid operator 0x00ffffffffffffffffffff00
    func test_unknown_1() throws {
        try verify_throwing_program(
            program: "ff02ffff01ff8c00ffffffffffffffffffff0080ffff01ff808080",
            expected_output: "invalid operator"
        )
    }
    
    // brun -c '(a (q 0xfffffffff) (q ()))'
    // FAIL: invalid operator 0x0fffffffff
    func test_unknown_2() throws {
        try verify_throwing_program(
            program: "ff02ffff01ff850fffffffff80ffff01ff808080",
            expected_output: "invalid operator"
        )
    }
    
//    // brun -c --strict '(a (q 0xff) (q 1))'
//    // FAIL: unimplemented operator -1
//    func test_unknown_3() throws {
//        try verify_throwing_program(
//            program: "ff02ffff01ff81ff80ffff01ff018080",
//            expected_output: "unimplemented operator"
//        )
//    }
    
}
