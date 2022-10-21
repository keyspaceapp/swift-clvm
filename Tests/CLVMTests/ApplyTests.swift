import XCTest

final class ApplyTests: XCTestCase {
    
    // brun -c '(a (q . 2) (q . (3 4 5)))'
    // cost = 179
    // 3
    func test_apply_0() throws {
        try verify_program(
            program: "ff02ffff0102ffff01ff03ff04ff058080",
            expected_output: "03",
            expected_cost: 179
        )
    }
    
    // brun -c '(a (q . 5) (q . (3 4 5)))'
    // cost = 183
    // 4
    func test_apply_1() throws {
        try verify_program(
            program: "ff02ffff0105ffff01ff03ff04ff058080",
            expected_output: "04",
            expected_cost: 183
        )
    }
    
    // brun -c '(a (q . 11) 1)' '(5 6 7 8 9)'
    // cost = 211
    // 7
    func test_apply_2() throws {
        try verify_program(
            program: "ff02ffff010bff0180",
            args: "ff05ff06ff07ff08ff0980",
            expected_output: "07",
            expected_cost: 211
        )
    }
    
    // brun -c '(a)'
    // FAIL: apply requires exactly 2 parameters ()
    func test_apply_3() throws {
        try verify_throwing_program(
            program: "ff0280",
            expected_output: "apply requires exactly 2 parameters"
        )
    }
    
    // brun -c '(a (q . +))'
    // FAIL: apply requires exactly 2 parameters (+)
    func test_apply_4() throws {
        try verify_throwing_program(
            program: "ff02ffff011080",
            expected_output: "apply requires exactly 2 parameters"
        )
    }
    
    // brun -c '(a (q . +) (q . (1 2 3)) (q . foo))'
    // FAIL: apply requires exactly 2 parameters (+ (q 2 3) "foo")
    func test_apply_5() throws {
        try verify_throwing_program(
            program: "ff02ffff0110ffff01ff01ff02ff0380ffff0183666f6f80",
            expected_output: "apply requires exactly 2 parameters"
        )
    }
    
    // brun -c '(a (q . (+ 2 5)) (q . (20 30)))'
    // cost = 987
    // 50
    func test_apply_6() throws {
        try verify_program(
            program: "ff02ffff01ff10ff02ff0580ffff01ff14ff1e8080",
            expected_output: "32",
            expected_cost: 987
        )
    }
    
    // brun --strict -c -n '(a (q . q) (q . (2 3 4)))'
    // cost = 175
    // (2 3 4)
    func test_apply_7() throws {
        try verify_program(
            program: "ff02ffff0101ffff01ff02ff03ff048080",
            expected_output: "ff02ff03ff0480",
            expected_cost: 175
        )
    }

}
