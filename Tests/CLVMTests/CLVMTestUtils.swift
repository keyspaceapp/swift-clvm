import Foundation
import XCTest
@testable import CLVM

func verify_program(
    program: String,
    args: String = "80",
    expected_output: String,
    expected_cost: Int? = nil
) throws {
    let (cost, result) = try run_serialized_program(
        program: [UInt8](Data(hex: program)),
        args: [UInt8](Data(hex: args)),
        max_cost: 0x7FFFFFFFFFFFFFFF,
        flags: 0
    )
    var stream = Data(hex: expected_output).makeIterator()
    XCTAssertEqual(result, try sexp_from_stream(f: &stream, to_sexp: SExp.to))
    if expected_cost != nil {
        XCTAssertEqual(cost, expected_cost)
    }
}

func verify_throwing_program(
    max_cost: UInt64? = nil,
    program: String,
    args: String = "80",
    expected_output: String
) throws {
    XCTAssertThrowsError(try run_serialized_program(
        program: [UInt8](Data(hex: program)),
        args: [UInt8](Data(hex: args)),
        max_cost: max_cost ?? 0x7FFFFFFFFFFFFFFF,
        flags: 0
    ), "", { error in
        let error = error as? EvalError
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.message, expected_output)
    })
}

extension Data {
    public init(hex: String) {
        self.init(Array<UInt8>(hex: hex))
    }
}

// Data(hex:)
// From https://github.com/krzyzanowskim/CryptoSwift/ (MIT)
extension Array where Element == UInt8 {
    public init(hex: String) {
        self.init()
        reserveCapacity(hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }
}
