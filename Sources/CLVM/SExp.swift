import Foundation
import BLS
import BigInt

public enum CastableType {
    case sexp (SExp)
    case object (CLVMObjectProtocol)
    case bytes (Data)
    case string (String)
    case int (BigInt)
    case g1 (G1Element)
    indirect case list ([CastableType])
    indirect case tuple ((CastableType, CastableType))
}

enum ConvertibleType {
    case bytes (Data)
    case string (String)
    case int (BigInt)
    case g1 (G1Element)
    case list ([Any])
}


let NULL = Data()


func looks_like_clvm_object(o: CastableType?) -> Bool {
    switch o {
    case .none:
        return false
    case .some(let obj):
        switch obj {
        case .sexp(_):
            return true
        case .object(_):
            return true
        default:
            return false
        }
    }
}

// this function recognizes some common types and turns them into plain bytes,
func convert_atom_to_bytes(v: ConvertibleType?) throws -> Data {
    switch v {
    case .bytes(let bytes):
        return bytes
    case .string(let string):
        return string.data(using: .utf8)!
    case .int(let int):
        return int_to_bytes(v: int)
    case .g1(let g1):
        return g1.get_bytes()
    case .none:
        return Data()
    case .list(let list):
        if list.count == 0 {
            return Data()
        }
    }
    
    throw(ValueError("can't cast \(v.debugDescription) to bytes"))
}

// returns a clvm-object like object
func to_sexp_type(
    v: CastableType?
) throws -> CLVMObjectProtocol {
    var stack: [CastableType?] = [v]
    var ops: [(Int, Int?)] = [(0, nil)]  // convert

    while ops.count > 0 {
        let (op, target) = ops.popLast()!
        // convert value
        if op == 0 {
            if looks_like_clvm_object(o: stack.last!) {
                continue
            }
            let v = stack.popLast()!
            switch v {
            case .tuple(let (left, right)):
                let target = stack.count
                stack.append(.object(CLVMObject(v: .tuple((left, right)))))
                if !looks_like_clvm_object(o: right) {
                    stack.append(right)
                    ops.append((2, target))  // set right
                    ops.append((0, nil))  // convert
                }
                if !looks_like_clvm_object(o: left) {
                    stack.append(left)
                    ops.append((1, target))  // set left
                    ops.append((0, nil))  // convert
                }
                continue
            case .list(let list):
                let target = stack.count
                stack.append(.object(CLVMObject(v: .bytes(NULL))))
                for list_item in list {
                    stack.append(list_item)
                    ops.append((3, target))  // prepend list
                    // we only need to convert if it's not already the right type
                    if !looks_like_clvm_object(o: list_item) {
                        ops.append((0, nil))  // convert
                    }
                }
                continue
            case .bytes(let v):
                stack.append(.object(CLVMObject(v: .bytes(try convert_atom_to_bytes(v: .bytes(v))))))
            case .string(let v):
                stack.append(.object(CLVMObject(v: .bytes(try convert_atom_to_bytes(v: .string(v))))))
            case .int(let v):
                stack.append(.object(CLVMObject(v: .bytes(try convert_atom_to_bytes(v: .int(v))))))
            case .g1(let g1):
                stack.append(.object(CLVMObject(v: .bytes(try convert_atom_to_bytes(v: .g1(g1))))))
            case .none:
                stack.append(.object(CLVMObject(v: .bytes(try convert_atom_to_bytes(v: nil)))))
            case .sexp(_):
                throw(ValueError("should never reach here"))
            case .object(_):
                throw(ValueError("should never reach here"))
            }
            continue
        }
        
        if op == 1 {  // set left
            if case var .object(stack_object) = stack[target!] {
                stack_object.pair = (CLVMObject(v: stack.popLast()!!), stack_object.pair!.1)
                continue
            } else {
                throw(ValueError("should never reach here"))
            }
        }
        if op == 2 {  // set right
            if case var .object(stack_object) = stack[target!] {
                stack_object.pair = (stack_object.pair!.0, CLVMObject(v: stack.popLast()!!))
                continue
            } else {
                throw(ValueError("internal error"))
            }
        }
        if op == 3 {  // prepend list
            stack[target!] = .list([stack.popLast()!!, stack[target!]!])
            continue
        }
    }
    // there's exactly one item left at this point
    if stack.count != 1 {
        throw(ValueError("internal error"))
    }

    // stack[0] implements the clvm object protocol and can be wrapped by an SExp
    return CLVMObject(v: stack[0]!)
}


/*
 SExp provides higher level API on top of any object implementing the CLVM
 object protocol.
 The tree of values is not a tree of SExp objects, it's a tree of CLVMObject
 like objects. SExp simply wraps them to privide a uniform view of any
 underlying conforming tree structure.

 The CLVM object protocol (concept) exposes two attributes:
 1. "atom" which is either None or bytes
 2. "pair" which is either None or a tuple of exactly two elements. Both
    elements implementing the CLVM object protocol.
 Exactly one of "atom" and "pair" must be nil.
*/
open class SExp: CLVMObjectProtocol, Equatable, CustomDebugStringConvertible {
    public var debugDescription: String {
        try! self.as_bin().map { String(format: "%02hhx", $0) }.joined() //.hex()
    }
    
    static let true_sexp: SExp = SExp(obj: CLVMObject(v: .bytes(Data([1]))))

    static let false_sexp: SExp = SExp(obj: CLVMObject(v: .bytes(Data())))

    static let __null__: SExp = SExp(obj: CLVMObject(v: .bytes(Data())))

    // the underlying object implementing the clvm object protocol
    public let atom: Data?

    // this is a tuple of the otherlying CLVMObject-like objects. i.e. not
    // SExp objects with higher level functions, or None
    public var pair: (CLVMObjectProtocol?, CLVMObjectProtocol?)?

    public required init(obj: CLVMObjectProtocol?) {
        self.atom = obj?.atom
        self.pair = obj?.pair
    }

    // this returns a tuple of two SExp objects, or None
    func as_pair() -> (SExp, SExp)? {
        guard let pair = self.pair else {
            return nil
        }
        return (SExp(obj: pair.0), SExp(obj: pair.1))
    }

    public func listp() -> Bool {
        return self.pair != nil
    }

    public func nullp() -> Bool {
        let v = self.atom
        return v != nil && v!.count == 0
    }

    public func as_int() -> BigInt {
        return int_from_bytes(blob: self.atom!)
    }

    public func as_bin() throws -> [UInt8] {
        try sexp_to_stream(sexp: self)
    }

    public static func to(v: CastableType?) throws -> Self {
        
        if case .sexp(let sexp) = v {
            return self.init(obj: sexp)
        }
        if looks_like_clvm_object(o: v) {
            return Self.init(obj: CLVMObject(v: v!))
        }

        // this will lazily convert elements
        return try self.init(obj: to_sexp_type(v: v))
    }

    public func cons(right: CastableType) throws -> SExp {
        let s = (CastableType.sexp(self), right)
        return try SExp.to(v: .tuple(s))
    }

    public func first() throws -> SExp {
        let pair = self.pair
        if pair != nil {
            return SExp(obj: pair!.0)
        }
        throw(EvalError(message: "first of non-cons", sexp: self))
    }

    public func rest() throws -> SExp {
        let pair = self.pair
        if pair != nil {
            return SExp(obj: pair!.1)
        }
        throw(EvalError(message: "rest of non-cons", sexp: self))
    }

    static func null() -> SExp {
        return SExp.__null__
    }

    public func as_iter() -> [SExp] { // python returns iterable
        var arr: [SExp] = []
        var v = self
        while !v.nullp() {
            arr.append(try! v.first())
            v = try! v.rest()
        }
        return arr
    }
    
    public static func == (lhs: SExp, rhs: CastableType) -> Bool {
        do {
            return try lhs == SExp.to(v: rhs)
        } catch {
            return false
        }
    }

    public static func == (lhs: SExp, rhs: SExp) -> Bool {
        let other = rhs
        var to_compare_stack = [(lhs, other)]
        while !to_compare_stack.isEmpty {
            let (s1, s2) = to_compare_stack.popLast()!
            let p1 = s1.as_pair()
            if p1 != nil {
                let p2 = s2.as_pair()
                if p2 != nil {
                    to_compare_stack.append((p1!.0, p2!.0))
                    to_compare_stack.append((p1!.1, p2!.1))
                }
                else {
                    return false
                }
            }
            else if s2.as_pair() != nil || s1.atom != s2.atom {
                return false
            }
        }
        return true
    }

    func list_len() throws -> Int {
        var v = self
        var size = 0
        while v.listp() {
            size += 1
            v = try v.rest()
        }
        return size
    }
}

struct SExpIterator: IteratorProtocol, Sequence {
    typealias Element = SExp
    
    var v: SExp
    
    init(_ v: SExp) {
        self.v = v
    }
    
    mutating func next() -> SExp? {
        if !v.nullp() {
            let return_v = try! v.first()
            v = try! v.rest()
            return return_v
        }
        return nil
    }
}
