import Foundation
import BinaryCodable

// decoding:
// read a byte
// if it's 0xfe, it's nil (which might be same as 0)
// if it's 0xff, it's a cons box. Read two items, build cons
// otherwise, number of leading set bits is length in bytes to read size
// 0-0x7f are literal one byte values
// leading bits is the count of bytes to read of size
// 0x80-0xbf is a size of one byte (perform logical and of first byte with 0x3f to get size)
// 0xc0-0xdf is a size of two bytes (perform logical and of first byte with 0x1f)
// 0xe0-0xef is 3 bytes ((perform logical and of first byte with 0xf))
// 0xf0-0xf7 is 4 bytes ((perform logical and of first byte with 0x7))
// 0xf7-0xfb is 5 bytes ((perform logical and of first byte with 0x3))

let MAX_SINGLE_BYTE: UInt8 = 0x7F
let CONS_BOX_MARKER: UInt8 = 0xFF

func sexp_to_byte_iterator(sexp: SExp) throws -> [UInt8] {
    var bytes: [UInt8] = []
    var todo_stack = [sexp]
    while !todo_stack.isEmpty {
        let sexp = todo_stack.popLast()!
        let pair = sexp.as_pair()
        if pair != nil {
            bytes.append(CONS_BOX_MARKER)
            todo_stack.append(pair!.1)
            todo_stack.append(pair!.0)
        }
        else {
            bytes.append(contentsOf: try atom_to_byte_iterator(atom: sexp.atom!))
        }
    }
    return bytes
}

struct AtomByteIterator: IteratorProtocol {
    typealias Element = UInt8
    
    let atom: Data
    var index = 0

    init(_ atom: Data) {
        self.atom = atom
    }

    mutating func next() -> UInt8? {
        if index == atom.count {
            return nil
        }
        let byte = atom[index]
        index += 1
        return byte
    }
}

func atom_to_byte_iterator(atom: Data) throws -> [UInt8] {
    var bytes: [UInt8] = []
    let size = atom.count
    if size == 0 {
        bytes.append(0x80)
        return bytes
    }
    if size == 1 {
        if atom[0] <= MAX_SINGLE_BYTE {
            bytes.append(atom[0])
            return bytes
        }
    }
    let size_blob: Data
    if size < 0x40 {
        size_blob = Data([0x80 | UInt8(size)])
    }
    else if size < 0x2000 {
        size_blob = Data([0xC0 | UInt8(size >> 8), UInt8((size >> 0) & 0xFF)])
    }
    else if size < 0x100000 {
        size_blob = Data([0xE0 | UInt8(size >> 16), UInt8((size >> 8) & 0xFF), UInt8((size >> 0) & 0xFF)])
    }
    else if size < 0x8000000 {
        size_blob = Data(
            [
                0xF0 | UInt8(size >> 24),
                UInt8((size >> 16) & 0xFF),
                UInt8((size >> 8) & 0xFF),
                UInt8((size >> 0) & 0xFF)
            ]
        )
    }
    else if size < 0x400000000 {
        size_blob = Data(
            [
                0xF8 | UInt8(size >> 32),
                UInt8((size >> 24) & 0xFF),
                UInt8((size >> 16) & 0xFF),
                UInt8((size >> 8) & 0xFF),
                UInt8((size >> 0) & 0xFF)
            ]
        )
    }
    else {
        throw(ValueError("sexp too long \(atom)"))
    }

    bytes.append(contentsOf: size_blob)
    bytes.append(contentsOf: atom)
    return bytes
}
        
public func sexp_to_stream(sexp: SExp) throws -> [UInt8] {
    var bytes: [UInt8] = []
    for b in try sexp_to_byte_iterator(sexp: sexp) {
        bytes.append(b)
    }
    return bytes
}

// indirect enum to handle recursive type
enum OpCallableSerialize {
    indirect case op((inout OpStackTypeSerialize, inout ValStackTypeSerialze, inout Data.Iterator, ((CastableType) throws -> SExp)) throws -> Void)
}

typealias ValStackTypeSerialze = [SExp]
typealias OpStackTypeSerialize = [OpCallableSerialize]


func _op_read_sexp(op_stack: inout OpStackTypeSerialize, val_stack: inout ValStackTypeSerialze, f: inout Data.Iterator, to_sexp: ((CastableType) throws -> SExp)) throws {
    guard let b = f.next() else {
        throw(ValueError("bad encoding"))
    }
    if b == CONS_BOX_MARKER {
        op_stack.append(OpCallableSerialize.op(_op_cons))
        op_stack.append(OpCallableSerialize.op(_op_read_sexp))
        op_stack.append(OpCallableSerialize.op(_op_read_sexp))
        return
    }
    val_stack.append(try _atom_from_stream(f: &f, b: b, to_sexp: to_sexp))
}

func _op_cons(op_stack: inout OpStackTypeSerialize, val_stack: inout ValStackTypeSerialze, f: inout Data.Iterator, to_sexp: ((CastableType) throws -> SExp)) throws {
    let right = val_stack.popLast()!
    let left = val_stack.popLast()!
    val_stack.append(try to_sexp(.tuple((.sexp(left), .sexp(right)))))
}

public func sexp_from_stream(f: inout Data.Iterator, to_sexp: ((CastableType) throws -> SExp)) throws -> SExp {
    var op_stack: OpStackTypeSerialize = [.op(_op_read_sexp)]
    var val_stack: ValStackType = []

    while op_stack.count > 0 {
        let op = op_stack.popLast()!
        func to_sexp(v: CastableType) -> SExp {
            SExp(obj: CLVMObject(v: v))
        }
        switch op {
        case .op(let op):
            try op(&op_stack, &val_stack, &f, to_sexp)
        }
    }
    return try to_sexp(.sexp(val_stack.popLast()!))
}

// Decodes the length prefix for an atom.
func decode_size(f: inout BinaryDecodingContainer, initial_b: UInt8, position: inout Int) throws -> UInt64 {
    assert((initial_b & 0x80) != 0)
    if (initial_b & 0x80) == 0 {
        // Atoms whose value fit in 7 bits don't have a length-prefix,
        // so those should never be passed to this function.
        throw ValueError("should never be passed")
    }
    
    var bit_count = 0
    var bit_mask: UInt8 = 0x80
    var b = initial_b
    while b & bit_mask != 0 {
        bit_count += 1
        b &= 0xFF ^ bit_mask
        bit_mask >>= 1
    }
    var size_blob = Data([b])
    if bit_count > 1 {
        let remaining_buffer = try read_exact(bit_count - 1, p: &position, f: &f)
        size_blob += remaining_buffer
    }
    // need to convert size_blob to an int
    var v: UInt64 = 0
    if size_blob.count > 6 {
        throw ValueError("bad encoding")
    }
    for b in size_blob {
        v <<= 8
        v += UInt64(b)
    }
    if v >= 0x400000000 {
        throw(ValueError("bad encoding"))
    }
    return UInt64(v)
}
    
enum ParseOp {
    case sexp
    case cons
}

private func read_exact(_ count: Int, p: inout Int, f: inout BinaryDecodingContainer) throws -> [UInt8] {
    p += count
    let peek = Array(try f.peek(length: p))
    return [UInt8](peek[peek.count-count..<peek.count])
}

public func serialized_length_from_bytes(f: inout BinaryDecodingContainer) throws -> UInt64 {
    var position = 0
    var ops: [ParseOp] = [.sexp]
    var b: [UInt8] = [0]
    while true {
        guard let op = ops.popLast() else {
            break
        }
        switch op {
        case .sexp:
            b = try read_exact(1, p: &position, f: &f)
            if b[0] == CONS_BOX_MARKER {
                // since all we're doing is to determing the length of the
                // serialized buffer, we don't need to do anything about
                // "cons". So we skip pushing it to lower the pressure on
                // the op stack
                //ops.push(ParseOp::Cons);
                ops.append(.sexp);
                ops.append(.sexp);
            } else if b[0] == 0x80 || b[0] <= MAX_SINGLE_BYTE {
                // This one byte we just read was the whole atom.
                // or the
                // special case of NIL
            } else {
                let blob_size = try decode_size(f: &f, initial_b: b[0], position: &position)
                position += Int(blob_size)
                do {
                    _ = try f.peek(length: Int(blob_size))
                } catch {
                    throw ValueError("bad encoding")
                }
            }
        case .cons:
            // cons. No need to construct any structure here. Just keep
            // going
            continue
        }
    }

    return UInt64(position)
}

public protocol DataIterator: IteratorProtocol {
    associatedtype Element = UInt8
    var index: Int { get }
    mutating func read(count: Int) -> Data
}

func _atom_from_stream(f: inout Data.Iterator, b: UInt8, to_sexp: ((CastableType) throws -> SExp)) throws -> SExp {
    if b == 0x80 {
        return try to_sexp(.bytes(Data()))
    }
    if b <= MAX_SINGLE_BYTE {
        return try to_sexp(.bytes(Data([b])))
    }
    var bit_count = 0
    var bit_mask: UInt8 = 0x80
    var b = b
    while b & bit_mask != 0 {
        bit_count += 1
        b &= 0xFF ^ bit_mask
        bit_mask >>= 1
    }
    var size_blob = Data([b])
    if bit_count > 1 {
        var b: [UInt8] = []
        for _ in 0..<bit_count - 1 {
            b.append(f.next()!)
        }
        if b.count != bit_count - 1 {
            throw(ValueError("bad encoding"))
        }
        size_blob += b
    }
    let size: Int = int_from_bytes(blob: size_blob)
    if size >= 0x400000000 {
        throw(ValueError("blob too large"))
    }
    var blob: [UInt8] = []
    for _ in 0..<size {
        blob.append(f.next()!)
    }
    if blob.count != size {
        throw(ValueError("bad encoding"))
    }
    return try to_sexp(.bytes(Data(blob)))
}
