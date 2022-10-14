import XCTest

final class DivmodTests: XCTestCase {

    // '(divmod 2 5)' '(80001 73)'
    // cost = 1271
    // (1095 . 66)
    func test_divmod_1() throws {
        try verify_program(
            program: "ff14ff02ff0580",
            args: "ff83013881ff4980",
            expected_output: "ff82044742",
            expected_cost: 1271
        )
    }
    
    // '(divmod 2 5)' '(-80001 73)'
    // cost = 1271
    // (-1096 . 7)
    func test_divmod_2() throws {
        try verify_program(
            program: "ff14ff02ff0580",
            args: "ff83fec77fff4980",
            expected_output: "ff82fbb807",
            expected_cost: 1271
        )
    }
    
    // '(divmod 2 5)' '(-80001 -73)'
    // cost = 1271
    // (-1096 . -7)
    func test_divmod_3() throws {
        try verify_program(
            program: "ff14ff02ff0580",
            args: "ff83013881ff81b780",
            expected_output: "ff82fbb881f9",
            expected_cost: 1271
        )
    }
    
    // '(divmod 2 5)' '(-80001 -73)'
    // cost = 1271
    // (1095 . -66)
    func test_divmod_4() throws {
        try verify_program(
            program: "ff14ff02ff0580",
            args: "ff83fec77fff81b780",
            expected_output: "ff82044781be",
            expected_cost: 1271
        )
    }
    
    // brun -c '(divmod 2 5)' '((200 80001) 73)'
    // FAIL: divmod requires int args (200 0x013881)
    func test_divmod_5() throws {
        try verify_throwing_program(
            program: "ff14ff02ff0580",
            args: "ffff8200c8ff8301388180ff4980",
            expected_output: "divmod requires int args"
        )
    }
    
    // brun -c '(divmod 2 5)' '(80001 (200 73))'
    // FAIL: divmod requires int args (200 73)
    func test_divmod_6() throws {
        try verify_throwing_program(
            program: "ff14ff02ff0580",
            args: "ff83013881ffff8200c8ff498080",
            expected_output: "divmod requires int args"
        )
    }
    
    // brun -c '(divmod 2 5)' '(80001 0)'
    // FAIL: divmod with 0 0x013881
    func test_divmod_7() throws {
        try verify_throwing_program(
            program: "ff14ff02ff0580",
            args: "ff83013881ff8080",
            expected_output: "divmod with 0"
        )
    }
    
    // brun -c '(divmod 2 5)' '(80000 10)'
    // cost = 1261
    // (8000)
    func test_divmod_8() throws {
        try verify_program(
            program: "ff14ff02ff0580",
            args: "ff83013880ff0a80",
            expected_output: "ff821f4080",
            expected_cost: 1261
        )
    }
    
    // brun -c '(divmod 2 5)' '(-80000 10)'
    // cost = 1261
    // (-8000)
    func test_divmod_9() throws {
        try verify_program(
            program: "ff14ff02ff0580",
            args: "ff83fec780ff0a80",
            expected_output: "ff82e0c080",
            expected_cost: 1261
        )
    }
    
    // brun -c '(divmod 2 5)' '(80000 -10)'
    // cost = 1261
    // (-8000)
    func test_divmod_10() throws {
        try verify_program(
            program: "ff14ff02ff0580",
            args: "ff83013880ff81f680",
            expected_output: "ff82e0c080",
            expected_cost: 1261
        )
    }
    
    // brun -c '(divmod (q . 0x0000000000000000000000000000000000000000000000000000000000000013881) (q . 0x0000000000000000000000000000000000000000000000000000049))'
    // cost = 1559
    // (1095 . 66)
    func test_divmod_11() throws {
        try verify_program(
            program: "ff14ffff01a200000000000000000000000000000000000000000000000000000000000000013881ffff019c0000000000000000000000000000000000000000000000000000004980",
            expected_output: "ff82044742",
            expected_cost: 1559
        )
    }
    
    // brun -n -c '(divmod (q . -10) (q . -7))'
    // cost = 1189
    // (1 . -3)
    func test_divmod_12() throws {
        try verify_program(
            program: "ff14ffff0181f6ffff0181f980",
            expected_output: "ff0181fd",
            expected_cost: 1189
        )
    }
    
    // brun -n -c '(divmod (q . -10) (q . 7))'
    // cost = 1189
    // (-2 . 4)
    func test_divmod_13() throws {
        try verify_program(
            program: "ff14ffff0181f6ffff010780",
            expected_output: "ff81fe04",
            expected_cost: 1189
        )
    }
    
    // brun -n -c '(divmod (q . 10) (q . -7))'
    // cost = 1189
    // (-2 . -4)
    func test_divmod_14() throws {
        try verify_program(
            program: "ff14ffff010affff0181f980",
            expected_output: "ff81fe81fc",
            expected_cost: 1189
        )
    }
    
    // brun -n -c '(divmod (q . 10) (q . 7))'
    // cost = 1189
    // (1 . 3)
    func test_divmod_15() throws {
        try verify_program(
            program: "ff14ffff010affff010780",
            expected_output: "ff0103",
            expected_cost: 1189
        )
    }
    
    // brun -n -c '(divmod (q . -10) (q . -70))'
    // cost = 1179
    // (() . -10)
    func test_divmod_16() throws {
        try verify_program(
            program: "ff14ffff0181f6ffff0181ba80",
            expected_output: "ff8081f6",
            expected_cost: 1179
        )
    }
    
    // brun -n -c '(divmod (q . -10) (q . 70))'
    // cost = 1189
    // (-1 . 60)
    func test_divmod_17() throws {
        try verify_program(
            program: "ff14ffff0181f6ffff014680",
            expected_output: "ff81ff3c",
            expected_cost: 1189
        )
    }
    
    // brun -n -c '(divmod (q . 10) (q . -70))'
    // cost = 1189
    // (-1 . -60)
    func test_divmod_18() throws {
        try verify_program(
            program: "ff14ffff010affff0181ba80",
            expected_output: "ff81ff81c4",
            expected_cost: 1189
        )
    }
    
    // brun -n -c '(divmod (q . 10) (q . 70))'
    // cost = 1179
    // (() . 10)
    func test_divmod_19() throws {
        try verify_program(
            program: "ff14ffff010affff014680",
            expected_output: "ff800a",
            expected_cost: 1179
        )
    }
    
    // brun -n -c '(divmod (q . -100) (q . -7))'
    // cost = 1189
    // (14 . -2)
    func test_divmod_20() throws {
        try verify_program(
            program: "ff14ffff01819cffff0181f980",
            expected_output: "ff0e81fe",
            expected_cost: 1189
        )
    }
    
    // brun -n -c '(divmod (q . -100) (q . 7))'
    // cost = 1189
    // (-15 . 5)
    func test_divmod_21() throws {
        try verify_program(
            program: "ff14ffff01819cffff010780",
            expected_output: "ff81f105",
            expected_cost: 1189
        )
    }
    
    // brun -n -c '(divmod (q . 100) (q . -7))'
    // cost = 1189
    // (-15 . -5)
    func test_divmod_22() throws {
        try verify_program(
            program: "ff14ffff0164ffff0181f980",
            expected_output: "ff81f181fb",
            expected_cost: 1189
        )
    }
    
    // brun -n -c '(divmod (q . 100) (q . 7))'
    // cost = 1189
    // (14 . 2)
    func test_divmod_23() throws {
        try verify_program(
            program: "ff14ffff0164ffff010780",
            expected_output: "ff0e02",
            expected_cost: 1189
        )
    }
    
    // brun -n -c '(divmod (q . -100) (q . -70))'
    // cost = 1189
    // (1 . -30)
    func test_divmod_24() throws {
        try verify_program(
            program: "ff14ffff01819cffff0181ba80",
            expected_output: "ff0181e2",
            expected_cost: 1189
        )
    }
    
    // brun -n -c '(divmod (q . -100) (q . 70))'
    // cost = 1189
    // (-2 . 40)
    func test_divmod_25() throws {
        try verify_program(
            program: "ff14ffff01819cffff014680",
            expected_output: "ff81fe28",
            expected_cost: 1189
        )
    }
    
    // brun -n -c '(divmod (q . 100) (q . -70))'
    // cost = 1189
    // (-2 . -40)
    func test_divmod_26() throws {
        try verify_program(
            program: "ff14ffff0164ffff0181ba80",
            expected_output: "ff81fe81d8",
            expected_cost: 1189
        )
    }
    
    // brun -n -c '(divmod (q . 100) (q . 70))'
    // cost = 1189
    // (1 . 30)
    func test_divmod_27() throws {
        try verify_program(
            program: "ff14ffff0164ffff014680",
            expected_output: "ff011e",
            expected_cost: 1189
        )
    }

}
