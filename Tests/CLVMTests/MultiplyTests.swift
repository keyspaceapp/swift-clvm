import XCTest

final class MultiplyTests: XCTestCase {
    
    // brun -c '(* (q . 7) (q . 2))'
    // cost = 1040
    // 14
    func test_multiply_1() throws {
        try verify_program(
            program: "ff12ffff0107ffff010280",
            expected_output: "0e",
            expected_cost: 1040
        )
    }
    
    // brun -c '(* (q . 1))'
    // cost = 123
    // 1
    func test_multiply_2() throws {
        try verify_program(
            program: "ff12ffff010180",
            expected_output: "01",
            expected_cost: 123
        )
    }
    
    // brun -c '(* ())'
    // cost = 137
    // ()
    func test_multiply_3() throws {
        try verify_program(
            program: "ff12ff8080",
            expected_output: "80",
            expected_cost: 137
        )
    }
    
    // brun -c '(*)'
    // cost = 103
    // 1
    func test_multiply_4() throws {
        try verify_program(
            program: "ff1280",
            expected_output: "01",
            expected_cost: 103
        )
    }
    
    // brun -c '(* (q . 0x00000000000000000000000000000000000000000000000000000000000000000000000007) (q . 0x000000000000000000000000000000000000000000000000000000000000000000000000000000002))'
    // cost = 1507
    // 14
    func test_multiply_5() throws {
        try verify_program(
            program: "ff12ffff01a500000000000000000000000000000000000000000000000000000000000000000000000007ffff01a9000000000000000000000000000000000000000000000000000000000000000000000000000000000280",
            expected_output: "0e",
            expected_cost: 1507
        )
    }
    
    // brun -c '(* (q . 7) (q . -1))'
    // cost = 1040
    // -7
    func test_multiply_6() throws {
        try verify_program(
            program: "ff12ffff0107ffff0181ff80",
            expected_output: "81f9",
            expected_cost: 1040
        )
    }
    
    // brun -c -m 10000 '(* (q . 10000000000000000000000000000000000) (q . 10000000000000000000000000000000) (q . 100000000000000000000000000000000000000) (q . 1000000000000000000000000000000) (q . 1000000000000000000000000000000) (q . 1000000000000000000000000000000) (q . 1000000000000000000000000000000) (q . 1000000000000000000000000000000) (q . 1000000000000000000000000000000) (q . 1000000000000000000000000000000) (q . 1000000000000000000000000000000) (q . 1000000000000000000000000000000) (q . 1000000000000000000000000000000) (q . 1000000000000000000000000000000) (q . 1000000000000000000000000000000))'
    // FAIL: cost exceeded 10000
    func test_multiply_7() throws {
        try verify_throwing_program(
            max_cost: 10000,
            program: "ff12ffff018f01ed09bead87c0378d8e6400000000ffff018d7e37be2022c0914b2680000000ffff01904b3b4ca85a86c47a098a224000000000ffff018d0c9f2c9cd04674edea40000000ffff018d0c9f2c9cd04674edea40000000ffff018d0c9f2c9cd04674edea40000000ffff018d0c9f2c9cd04674edea40000000ffff018d0c9f2c9cd04674edea40000000ffff018d0c9f2c9cd04674edea40000000ffff018d0c9f2c9cd04674edea40000000ffff018d0c9f2c9cd04674edea40000000ffff018d0c9f2c9cd04674edea40000000ffff018d0c9f2c9cd04674edea40000000ffff018d0c9f2c9cd04674edea40000000ffff018d0c9f2c9cd04674edea4000000080",
            expected_output: "cost exceeded"
        )
    }

}
