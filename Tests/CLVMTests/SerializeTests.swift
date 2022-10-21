@testable import CLVM
import XCTest
import BinaryCodable

final class SerializeTests: XCTestCase {
    
    func test_serialized_length_from_bytes() throws {
        XCTAssertEqual(try serialized_length([0x7f, 0x00, 0x00, 0x00]), 1)
        XCTAssertEqual(try serialized_length([0x80, 0x00, 0x00, 0x00]), 1)
        XCTAssertEqual(try serialized_length([0xff, 0x00, 0x00, 0x00]), 3)
        XCTAssertEqual(try serialized_length([0xff, 0x01, 0xff, 0x80, 0x80, 0x00]), 5)
        XCTAssertThrowsError(try serialized_length([0x8f, 0xff])) { error in
            XCTAssertEqual((error as? ValueError)?.message, "bad encoding")
        }
        XCTAssertThrowsError(try serialized_length([0b11001111, 0xff])) { error in
            XCTAssertEqual((error as? ValueError)?.message, "bad encoding")
        }
        XCTAssertThrowsError(try serialized_length([0b11001111, 0xff, 0, 0])) { error in
            XCTAssertEqual((error as? ValueError)?.message, "bad encoding")
        }
        XCTAssertEqual(try serialized_length([0x8f, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), 16)
    }

    func test_decode_size() throws {
        // single-byte length prefix
        XCTAssertEqual(try decode_size(data: Data(), initial_b: 0x80 | 0x20), 0x20)
        
        // two-byte length prefix
        XCTAssertEqual(try decode_size(data: Data([0xaa]), initial_b: 0b11001111), 0xfaa)
    }
    
    func test_large_decode_size() throws {
        // this is an atom length-prefix 0xffffffffffff, or (2^48 - 1).
        // We don't support atoms this large and we should fail before attempting to
        // allocate this much memory
        var first: UInt8 = 0b11111110;
        var buffer = Data([0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
        XCTAssertThrowsError(try decode_size(data: buffer, initial_b: first)) { error in
            XCTAssertEqual((error as? ValueError)?.message, "bad encoding")
        }

        // this is still too large
        first = 0b11111100
        buffer = Data([0x4, 0, 0, 0, 0])
        XCTAssertThrowsError(try decode_size(data: buffer, initial_b: first)) { error in
            XCTAssertEqual((error as? ValueError)?.message, "bad encoding")
        }

        // But this is *just* within what we support
        // Still a very large blob, probably enough for a DoS attack
        first = 0b11111100
        buffer = Data([0x3, 0xff, 0xff, 0xff, 0xff])
        XCTAssertEqual(try decode_size(data: buffer, initial_b: first), 0x3ffffffff)
    }
    
    func test_truncated_decode_size() throws {
        // this is an atom length-prefix 0xffffffffffff, or (2^48 - 1).
        // We don't support atoms this large and we should fail before attempting to
        // allocate this much memory
        let first: UInt8 = 0b11111100;
        let buffer = Data([0x4, 0, 0, 0])
        XCTAssertThrowsError(try decode_size(data: buffer, initial_b: first)) { error in
            XCTAssertNotNil(error as? BinaryDecodingError)
        }
    }
    
}

private func serialized_length(_ bytes: [UInt8]) throws -> UInt64 {
    struct TestData: BinaryDecodable {
        let length: UInt64
        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            length = try serialized_length_from_bytes(f: &container)
        }
    }
    return try BinaryDataDecoder().decode(TestData.self, from: Data(bytes)).length
}

private func decode_size(data: Data, initial_b: UInt8) throws -> UInt64 {
    struct TestData: BinaryDecodable {
        let size: UInt64
        init(from decoder: BinaryDecoder) throws {
            var container = decoder.container(maxLength: nil)
            let initial_b = try container.decode(length: 1).first!
            var position = 0
            size = try decode_size(f: &container, initial_b: initial_b, position: &position)
        }
    }
    
    return try BinaryDataDecoder().decode(TestData.self, from: Data([initial_b]) + data).size
}
