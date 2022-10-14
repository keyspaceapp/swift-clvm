import XCTest

final class SubstrTests: XCTestCase {
    
    // brun -c '(substr (q . "abcdefghijkl") (q . 14))'
    // FAIL: invalid indices for substr ("abcdefghijkl" 14)
    func test_substr_0() throws {
        try verify_throwing_program(
            program: "ff0cffff018c6162636465666768696a6b6cffff010e80",
            expected_output: "invalid indices for substr"
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") (q . 0))'
    // cost = 42
    // "abcdefghijkl"
    func test_substr_1() throws {
        try verify_program(
            program: "ff0cffff018c6162636465666768696a6b6cffff018080",
            expected_output: "8c6162636465666768696a6b6c",
            expected_cost: 42
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") (q . -1))'
    // FAIL: invalid indices for substr ("abcdefghijkl" -1)
    func test_substr_2() throws {
        try verify_throwing_program(
            program: "ff0cffff018c6162636465666768696a6b6cffff0181ff80",
            expected_output: "invalid indices for substr"
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") (q . 12))'
    // cost = 42
    // ()
    func test_substr_3() throws {
        try verify_program(
            program: "ff0cffff018c6162636465666768696a6b6cffff010c80",
            expected_output: "80",
            expected_cost: 42
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") (q . 11))'
    // cost = 42
    // 108
    func test_substr_4() throws {
        try verify_program(
            program: "ff0cffff018c6162636465666768696a6b6cffff010b80",
            expected_output: "6c",
            expected_cost: 42
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") 2 5)' '(0 4)'
    // cost = 122
    // "abcd"
    func test_substr_5() throws {
        try verify_program(
            program: "ff0cffff018c6162636465666768696a6b6cff02ff0580",
            args: "ff80ff0480",
            expected_output: "8461626364",
            expected_cost: 122
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") 2 5)' '(0 12)'
    // cost = 122
    // "abcdefghijkl"
    func test_substr_6() throws {
        try verify_program(
            program: "ff0cffff018c6162636465666768696a6b6cff02ff0580",
            args: "ff80ff0c80",
            expected_output: "8c6162636465666768696a6b6c",
            expected_cost: 122
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") 2 5)' '(-1 12)'
    // FAIL: invalid indices for substr ("abcdefghijkl" -1 12)
    func test_substr_7() throws {
        try verify_throwing_program(
            program: "ff0cffff018c6162636465666768696a6b6cff02ff0580",
            args: "ff81ffff0c80",
            expected_output: "invalid indices for substr"
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") 2 5)' '(0 13)'
    // FAIL: invalid indices for substr ("abcdefghijkl" () 13)
    func test_substr_8() throws {
        try verify_throwing_program(
            program: "ff0cffff018c6162636465666768696a6b6cff02ff0580",
            args: "ff80ff0d80",
            expected_output: "invalid indices for substr"
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") 2 5)' '(10 10)'
    // cost = 122
    // ()
    func test_substr_9() throws {
        try verify_program(
            program: "ff0cffff018c6162636465666768696a6b6cff02ff0580",
            args: "ff0aff0a80",
            expected_output: "80",
            expected_cost: 122
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") 2 5)' '(10 9)'
    // FAIL: invalid indices for substr ("abcdefghijkl" 10 9)
    func test_substr_10() throws {
        try verify_throwing_program(
            program: "ff0cffff018c6162636465666768696a6b6cff02ff0580",
            args: "ff0aff0980",
            expected_output: "invalid indices for substr"
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") 2 5)' '(1 4)'
    // cost = 122
    // "bcd"
    func test_substr_11() throws {
        try verify_program(
            program: "ff0cffff018c6162636465666768696a6b6cff02ff0580",
            args: "ff01ff0480",
            expected_output: "83626364",
            expected_cost: 122
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") 2 5)' '(8 12)'
    // cost = 122
    // "ijkl"
    func test_substr_12() throws {
        try verify_program(
            program: "ff0cffff018c6162636465666768696a6b6cff02ff0580",
            args: "ff08ff0c80",
            expected_output: "84696a6b6c",
            expected_cost: 122
        )
    }
    
    // brun -c '(substr (q . ("abcdefghijkl")) 2 5)' '(0 4)'
    // FAIL: substr on list ("abcdefghijkl")
    func test_substr_13() throws {
        try verify_throwing_program(
            program: "ff0cffff01ff8c6162636465666768696a6b6c80ff02ff0580",
            args: "ff80ff0480",
            expected_output: "substr on list"
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") 2 5)' '((0) 4)'
    // FAIL: substr requires int32 args (())
    func test_substr_14() throws {
        try verify_throwing_program(
            program: "ff0cffff018c6162636465666768696a6b6cff02ff0580",
            args: "ffff8080ff0480",
            expected_output: "substr requires int32 args"
        )
    }
    
    // brun -n -c '(substr (q . "abcdefghijkl") 2 5)' '(0 (4))'
    // FAIL: substr requires int32 args (4)
    func test_substr_15() throws {
        try verify_throwing_program(
            program: "ff0cffff018c6162636465666768696a6b6cff02ff0580",
            args: "ff80ffff048080",
            expected_output: "substr requires int32 args"
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") (q . 0x000000000000000000000000000000000000000000000000000000000000000002) (q . 0x0000000000000000000000000000000000000000000000000000000000000005))'
    // FAIL: substr requires int32 args (with no leading zeros) 0x000000000000000000000000000000000000000000000000000000000000000002
    func test_substr_16() throws {
        try verify_throwing_program(
            program: "ff0cffff018c6162636465666768696a6b6cffff01a1000000000000000000000000000000000000000000000000000000000000000002ffff01a0000000000000000000000000000000000000000000000000000000000000000580",
            expected_output: "substr requires int32 args (with no leading zeros)"
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") 2 5)' '(0 -1)'
    // FAIL: invalid indices for substr ("abcdefghijkl" () -1)
    func test_substr_17() throws {
        try verify_throwing_program(
            program: "ff0cffff018c6162636465666768696a6b6cff02ff0580",
            args: "ff80ff81ff80",
            expected_output: "invalid indices for substr"
        )
    }
    
    // brun -c '(substr (q . "abcdefghijkl") 2 5)' '(4294967297 3)'
    // FAIL: substr requires int32 args (with no leading zeros) 0x0100000001
    func test_substr_18() throws {
        try verify_throwing_program(
            program: "ff0cffff018c6162636465666768696a6b6cff02ff0580",
            args: "ff850100000001ff0380",
            expected_output: "substr requires int32 args (with no leading zeros)"
        )
    }

}
