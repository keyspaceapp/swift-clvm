import XCTest

final class ArgsTests: XCTestCase {
    
    // brun -n -c 0 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 44
    // ()
    func test_args_0() throws {
        try verify_program(
            program: "80",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "80",
            expected_cost: 44
        )
    }
    
    // brun -n -c 1 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 44
    // (((8 . 12) 10 . 14) (9 . 13) 11 . 15)
    func test_args_1() throws {
        try verify_program(
            program: "01",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "ffffff080cff0a0effff090dff0b0f",
            expected_cost: 44
        )
    }
    
    // brun -n -c 2 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 48
    // ((8 . 12) 10 . 14)
    func test_args_2() throws {
        try verify_program(
            program: "02",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "ffff080cff0a0e",
            expected_cost: 48
        )
    }
    
    // brun -n -c 3 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 48
    // ((9 . 13) 11 . 15)
    func test_args_3() throws {
        try verify_program(
            program: "03",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "ffff090dff0b0f",
            expected_cost: 48
        )
    }
    
    // brun -n -c 4 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 52
    // (8 . 12)
    func test_args_4() throws {
        try verify_program(
            program: "04",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "ff080c",
            expected_cost: 52
        )
    }
    
    // brun -n -c 5 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 52
    // (9 . 13)
    func test_args_5() throws {
        try verify_program(
            program: "05",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "ff090d",
            expected_cost: 52
        )
    }
    
    // brun -n -c 6 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 52
    // (10 . 14)
    func test_args_6() throws {
        try verify_program(
            program: "06",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "ff0a0e",
            expected_cost: 52
        )
    }
    
    // brun -n -c 7 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 52
    // (11 . 15)
    func test_args_7() throws {
        try verify_program(
            program: "07",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "ff0b0f",
            expected_cost: 52
        )
    }
    
    // brun -n -c 8 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 56
    // 8
    func test_args_8() throws {
        try verify_program(
            program: "08",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "08",
            expected_cost: 56
        )
    }
    
    // brun -n -c 9 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 56
    // 9
    func test_args_9() throws {
        try verify_program(
            program: "09",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "09",
            expected_cost: 56
        )
    }
    
    // brun -n -c 10 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 56
    // 10
    func test_args_10() throws {
        try verify_program(
            program: "0a",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "0a",
            expected_cost: 56
        )
    }
    
    // brun -n -c 11 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 56
    // 11
    func test_args_11() throws {
        try verify_program(
            program: "0b",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "0b",
            expected_cost: 56
        )
    }
    
    // brun -n -c 12 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 56
    // 12
    func test_args_12() throws {
        try verify_program(
            program: "0c",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "0c",
            expected_cost: 56
        )
    }
    
    // brun -n -c 13 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 56
    // 13
    func test_args_13() throws {
        try verify_program(
            program: "0d",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "0d",
            expected_cost: 56
        )
    }
    
    // brun -n -c 14 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 56
    // 14
    func test_args_14() throws {
        try verify_program(
            program: "0e",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "0e",
            expected_cost: 56
        )
    }
    
    // brun -n -c 15 '(((8 . 12) . (10 . 14)) . ((9 . 13) . (11 . 15)))'
    // cost = 56
    // 15
    func test_args_15() throws {
        try verify_program(
            program: "0f",
            args: "ffffff080cff0a0effff090dff0b0f",
            expected_output: "0f",
            expected_cost: 56
        )
    }

}
