import XCTest

final class PubkeyForExpTests: XCTestCase {
    
    // brun -c '(pubkey_for_exp (q . 1))'
    // cost = 1326269
    // 0x97f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb
    func test_pubkey_for_exp_1() throws {
        try verify_program(
            program: "ff1effff010180",
            expected_output: "b097f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb",
            expected_cost: 1326269
        )
    }
    
    // brun -c '(pubkey_for_exp (q . 2))'
    // cost = 1326269
    // 0xa572cbea904d67468808c8eb50a9450c9721db309128012543902d0ac358a62ae28f75bb8f1c7c42c39a8c5529bf0f4e
    func test_pubkey_for_exp_2() throws {
        try verify_program(
            program: "ff1effff010280",
            expected_output: "b0a572cbea904d67468808c8eb50a9450c9721db309128012543902d0ac358a62ae28f75bb8f1c7c42c39a8c5529bf0f4e",
            expected_cost: 1326269
        )
    }
    
    // brun -c '(pubkey_for_exp (q . 3))'
    // cost = 1326269
    // 0x89ece308f9d1f0131765212deca99697b112d61f9be9a5f1f3780a51335b3ff981747a0b2ca2179b96d2c0c9024e5224
    func test_pubkey_for_exp_3() throws {
        try verify_program(
            program: "ff1effff010380",
            expected_output: "b089ece308f9d1f0131765212deca99697b112d61f9be9a5f1f3780a51335b3ff981747a0b2ca2179b96d2c0c9024e5224",
            expected_cost: 1326269
        )
    }
    
    // brun -c '(pubkey_for_exp (q . -2))'
    // cost = 1326269
    // 0x8572cbea904d67468808c8eb50a9450c9721db309128012543902d0ac358a62ae28f75bb8f1c7c42c39a8c5529bf0f4e
    func test_pubkey_for_exp_4() throws {
        try verify_program(
            program: "ff1effff0181fe80",
            expected_output: "b08572cbea904d67468808c8eb50a9450c9721db309128012543902d0ac358a62ae28f75bb8f1c7c42c39a8c5529bf0f4e",
            expected_cost: 1326269
        )
    }
    
    // brun -c '(pubkey_for_exp (q . 5))'
    // cost = 1326269
    // 0xb0e7791fb972fe014159aa33a98622da3cdc98ff707965e536d8636b5fcc5ac7a91a8c46e59a00dca575af0f18fb13dc
    func test_pubkey_for_exp_5() throws {
        try verify_program(
            program: "ff1effff010580",
            expected_output: "b0b0e7791fb972fe014159aa33a98622da3cdc98ff707965e536d8636b5fcc5ac7a91a8c46e59a00dca575af0f18fb13dc",
            expected_cost: 1326269
        )
    }
    
}
