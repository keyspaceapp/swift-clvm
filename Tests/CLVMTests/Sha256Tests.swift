import XCTest

final class Sha256Tests: XCTestCase {
    
    // brun -c '(sha256 (f 1))' '("hello.there.my.dear.friend")'
    // cost = 669
    // 0x5272821c151fdd49f19cc58cf8833da5781c7478a36d500e8dc2364be39f8216
    func test_sha256_1() throws {
        try verify_program(
            program: "ff0bffff05ff018080",
            args: "ff9a68656c6c6f2e74686572652e6d792e646561722e667269656e6480",
            expected_output: "a05272821c151fdd49f19cc58cf8833da5781c7478a36d500e8dc2364be39f8216",
            expected_cost: 669
        )
    }
    
    // brun -c '(sha256 (q . "hel") (q . "lo.there.my.dear.friend"))'
    // cost = 768
    // 0x5272821c151fdd49f19cc58cf8833da5781c7478a36d500e8dc2364be39f8216
    func test_sha256_2() throws {
        try verify_program(
            program: "ff0bffff018368656cffff01976c6f2e74686572652e6d792e646561722e667269656e6480",
            expected_output: "a05272821c151fdd49f19cc58cf8833da5781c7478a36d500e8dc2364be39f8216",
            expected_cost: 768
        )
    }
    
    // brun -c '(sha256 (f 1) (f (r 1)))' '("hel" "lo.there.my.dear.friend")'
    // cost = 909
    // 0x5272821c151fdd49f19cc58cf8833da5781c7478a36d500e8dc2364be39f8216
    func test_sha256_3() throws {
        try verify_program(
            program: "ff0bffff05ff0180ffff05ffff06ff01808080",
            args: "ff8368656cff976c6f2e74686572652e6d792e646561722e667269656e6480",
            expected_output: "a05272821c151fdd49f19cc58cf8833da5781c7478a36d500e8dc2364be39f8216",
            expected_cost: 909
        )
    }
    
    // brun -c '(sha256 1)' '(hello)'
    // FAIL: sha256 on list ("hello")
    func test_sha256_4() throws {
        try verify_throwing_program(
            program: "ff0bff0180",
            args: "ff8568656c6c6f80",
            expected_output: "sha256 on list"
        )
    }
    
}
