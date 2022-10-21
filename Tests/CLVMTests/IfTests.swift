import XCTest

final class IfTests: XCTestCase {
    
    // brun -c '(i (q . 100) (q . 200) (q . 300))'
    // cost = 94
    // 200
    func test_if_1() throws {
        try verify_program(
            program: "ff03ffff0164ffff018200c8ffff0182012c80",
            expected_output: "8200c8",
            expected_cost: 94
        )
    }
    
    // brun -c '(i (q . ()) (q . 200) (q . 300))'
    // cost = 94
    // 300
    func test_if_2() throws {
        try verify_program(
            program: "ff03ffff0180ffff018200c8ffff0182012c80",
            expected_output: "82012c",
            expected_cost: 94
        )
    }
    
    // brun -c '(i (q . 1) (q . 200) (q . 300))'
    // cost = 94
    // 200
    func test_if_3() throws {
        try verify_program(
            program: "ff03ffff0101ffff018200c8ffff0182012c80",
            expected_output: "8200c8",
            expected_cost: 94
        )
    }
    
    // brun -c '(i (f (r (r 1))) (f 1) (f (r 1)))' '(200 300 400)'
    // cost = 352
    // 200
    func test_if_4() throws {
        try verify_program(
            program: "ff03ffff05ffff06ffff06ff01808080ffff05ff0180ffff05ffff06ff01808080",
            args: "ff8200c8ff82012cff82019080",
            expected_output: "8200c8",
            expected_cost: 352
        )
    }
    
    // brun -c '(i (f (r (r 1))) (f 1) (f (r 1)))' '(200 300 1)'
    // cost = 352
    // 200
    func test_if_5() throws {
        try verify_program(
            program: "ff03ffff05ffff06ffff06ff01808080ffff05ff0180ffff05ffff06ff01808080",
            args: "ff8200c8ff82012cff0180",
            expected_output: "8200c8",
            expected_cost: 352
        )
    }
}
