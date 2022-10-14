import XCTest

final class PointAddTests: XCTestCase {
    
    // brun -c '(point_add (pubkey_for_exp (q . 1)) (pubkey_for_exp (q . 2)))'
    // cost = 5442073
    // 0x89ece308f9d1f0131765212deca99697b112d61f9be9a5f1f3780a51335b3ff981747a0b2ca2179b96d2c0c9024e5224
    func test_point_add_1() throws {
        try verify_program(
            program: "ff1dffff1effff010180ffff1effff01028080",
            expected_output: "b089ece308f9d1f0131765212deca99697b112d61f9be9a5f1f3780a51335b3ff981747a0b2ca2179b96d2c0c9024e5224",
            expected_cost: 5442073
        )
    }
    
    // brun -c '(= (point_add (pubkey_for_exp (q . 2)) (pubkey_for_exp (q . 3))) (pubkey_for_exp (q . 5)))// '
    // cost = 6768556
    // 1
    func test_point_add_2() throws {
        try verify_program(
            program: "ff09ffff1dffff1effff010280ffff1effff01038080ffff1effff01058080",
            expected_output: "01",
            expected_cost: 6768556
        )
    }
    
    // brun -c '(= (point_add (pubkey_for_exp (q . -2)) (pubkey_for_exp (q . 5))) (pubkey_for_exp (q . 3)))'
    // cost = 6768556
    // 1
    func test_point_add_3() throws {
        try verify_program(
            program: "ff09ffff1dffff1effff0181fe80ffff1effff01058080ffff1effff01038080",
            expected_output: "01"
        )
    }

}
