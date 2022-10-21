import XCTest

final class IntTests: XCTestCase {
    
    // brun -d '(q . 127)'
    // 7f
    func test_int_0() throws {
        try verify_program(
            program: "ff017f",
            expected_output: "7f"
        )
    }
    
    // brun -d '(q . 128)'
    // 820080
    func test_int_1() throws {
        try verify_program(
            program: "ff01820080",
            expected_output: "820080"
        )
    }
    
    // brun -d '(q . -127)'
    // 8181
    func test_int_2() throws {
        try verify_program(
            program: "ff018181",
            expected_output: "8181"
        )
    }
    
    // brun -d '(q . -128)'
    // 8180
    func test_int_3() throws {
        try verify_program(
            program: "ff018180",
            expected_output: "8180"
        )
    }
    
    // brun -d '(q . 32767)'
    // 827fff
    func test_int_4() throws {
        try verify_program(
            program: "ff01827fff",
            expected_output: "827fff"
        )
    }
    
    // brun -d '(q . 32768)'
    // 83008000
    func test_int_5() throws {
        try verify_program(
            program: "ff0183008000",
            expected_output: "83008000"
        )
    }
    
    // brun -d '(q . -32767)'
    // 828001
    func test_int_6() throws {
        try verify_program(
            program: "ff01828001",
            expected_output: "828001"
        )
    }
    
    // brun -d '(q . -32768)'
    // 828000
    func test_int_7() throws {
        try verify_program(
            program: "ff01828000",
            expected_output: "828000"
        )
    }
}
