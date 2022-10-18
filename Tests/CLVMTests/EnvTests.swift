import XCTest

final class EnvTests: XCTestCase {
    
    // brun -c '1' '(100)'
    // cost = 44
    // (100)
    func test_env_1() throws {
        try verify_program(
            program: "01",
            args: "ff6480",
            expected_output: "ff6480",
            expected_cost: 44
        )
    }
    
    // brun -c '1' '(990)'
    // cost = 44
    // (990)
    func test_env_2() throws {
        try verify_program(
            program: "01",
            args: "ff8203de80",
            expected_output: "ff8203de80",
            expected_cost: 44
        )
    }
    
    // brun -c '1'
    // cost = 44
    // ()
    func test_env_3() throws {
        try verify_program(
            program: "01",
            expected_output: "80",
            expected_cost: 44
        )
    }
    
    // brun -c '1' '(100 200)'
    // cost = 44
    // (100 200)
    func test_env_4() throws {
        try verify_program(
            program: "01",
            args: "ff64ff8200c880",
            expected_output: "ff64ff8200c880",
            expected_cost: 44
        )
    }
    
    // brun -c '1' '((100 101 102) 105)'
    // cost = 44
    // ((100 101 102) 105)
    func test_env_5() throws {
        try verify_program(
            program: "01",
            args: "ffff64ff65ff6680ff6980",
            expected_output: "ffff64ff65ff6680ff6980",
            expected_cost: 44
        )
    }

}
