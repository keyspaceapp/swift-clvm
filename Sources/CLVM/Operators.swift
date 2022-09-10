import Foundation

let KEYWORDS = (
    // core opcodes 0x01-x08
    ". q a i c f r l x " +

    // opcodes on atoms as strings 0x09-0x0f
    "= >s sha256 substr strlen concat . " +

    // opcodes on atoms as ints 0x10-0x17
    "+ - * / divmod > ash lsh " +

    // opcodes on atoms as vectors of bools 0x18-0x1c
    "logand logior logxor lognot . " +

    // opcodes for bls 1381 0x1d-0x1f
    "point_add pubkey_for_exp . " +

    // bool opcodes 0x20-0x23
    "not any all . " +

    // misc 0x24
    "softfork "
).split(separator: " ")

public let KEYWORD_FROM_ATOM = KEYWORDS.enumerated().reduce(into: [Data: String](), { partialResult, enumerated_keyword in
    let (index, keyword) = enumerated_keyword
    partialResult[int_to_bytes(v: index)] = String(keyword)
})

public let KEYWORD_TO_ATOM = KEYWORD_FROM_ATOM.reduce(into: [String: Data](), { partialResult, enumerated_keyword in
    let (key, value) = enumerated_keyword
    partialResult[value] = key
})

//{v: k for k, v in KEYWORD_FROM_ATOM.items()}

public let OP_REWRITE = [
    "+": "add",
    "-": "subtract",
    "*": "multiply",
    "/": "div",
    "i": "if",
    "c": "cons",
    "f": "first",
    "r": "rest",
    "l": "listp",
    "x": "raise",
    "=": "eq",
    ">": "gr",
    ">s": "gr_bytes",
]

func args_len(op_name: String, args: SExp) throws -> IndexingIterator<[Int]> { // should return iterable
    return try args.as_iter().map { (arg: SExp) in
        if arg.pair != nil {
            throw(EvalError(message: "\(op_name) requires int args", sexp: arg))
        }
        return arg.atom!.count
    }.makeIterator()
}

// unknown ops are reserved if they start with 0xffff
// otherwise, unknown ops are no-ops, but they have costs. The cost is computed
// like this:

// byte index (reverse):
// | 4 | 3 | 2 | 1 | 0          |
// +---+---+---+---+------------+
// | multiplier    |XX | XXXXXX |
// +---+---+---+---+---+--------+
//  ^               ^    ^
//  |               |    + 6 bits ignored when computing cost
// cost_multiplier  |
//                  + 2 bits
//                    cost_function

// 1 is always added to the multiplier before using it to multiply the cost, this
// is since cost may not be 0.

// cost_function is 2 bits and defines how cost is computed based on arguments:
// 0: constant, cost is 1 * (multiplier + 1)
// 1: computed like operator add, multiplied by (multiplier + 1)
// 2: computed like operator mul, multiplied by (multiplier + 1)
// 3: computed like operator concat, multiplied by (multiplier + 1)

// this means that unknown ops where cost_function is 1, 2, or 3, may still be
// fatal errors if the arguments passed are not atoms.

func default_unknown_op(op: Data, args: SExp) throws -> (Int, CLVMObjectProtocol) {
    // any opcode starting with ffff is reserved (i.e. fatal error)
    // opcodes are not allowed to be empty
    if op.count == 0 || (op.count >= 2 && op[0..<2] == Data([255, 255])) { // b"\xff\xff"
        throw(EvalError(message: "reserved operator", sexp: try SExp.to(v: .bytes(op))))
    }

    // all other unknown opcodes are no-ops
    // the cost of the no-ops is determined by the opcode number, except the
    // 6 least significant bits.

    let cost_function = (op.last! & 0b11000000) >> 6
    // the multiplier cannot be 0. it starts at 1

    if op.count > 5 {
        throw(EvalError(message: "invalid operator", sexp: try SExp.to(v: .bytes(op))))
    }

    let cost_multiplier = Int.from_bytes(op[0..<op.count-1], endian: .big, signed: false) + 1

    // 0 = constant
    // 1 = like op_add/op_sub
    // 2 = like op_multiply
    // 3 = like op_concat
    var cost: Int = 0
    if cost_function == 0 {
        cost = 1
    }
    else if cost_function == 1 {
        // like op_add
        cost = ARITH_BASE_COST
        var arg_size = 0
        for length in try args_len(op_name: "unknown op", args: SExp(obj: args)) {
            arg_size += length
            cost += ARITH_COST_PER_ARG
        }
        cost += arg_size * ARITH_COST_PER_BYTE
    }
    else if cost_function == 2 {
        // like op_multiply
        cost = MUL_BASE_COST
        let operands = try args_len(op_name: "unknown op", args: SExp(obj: args))
        for vs in operands {
            var vs = vs
            for rs in operands {
                cost += MUL_COST_PER_OP
                cost += (rs + vs) * MUL_LINEAR_COST_PER_BYTE
                cost += (rs * vs) // MUL_SQUARE_COST_PER_BYTE_DIVIDER
                // this is an estimate, since we don't want to actually multiply the
                // values
                vs += rs
            }
        }
    }

    else if cost_function == 3 {
        // like concat
        cost = CONCAT_BASE_COST
        var length = 0
        for arg in args.as_iter() {
            if arg.pair != nil {
                throw(EvalError(message: "unknown op on list", sexp: arg))
            }
            cost += CONCAT_COST_PER_ARG
            length += arg.atom!.count
        }
        cost += length * CONCAT_COST_PER_BYTE
    }

    cost *= cost_multiplier
    if cost >= UINT32_MAX { // 2**32
        throw(EvalError(message: "invalid operator", sexp: try SExp.to(v: .bytes(op))))
    }

    return (cost, SExp.null())
}


// This is a nice hack that adds `__call__` to a dictionary, so
// operators can be added dynamically.
public class OperatorDict {
    var d: [Data: (SExp) throws -> (Int, CLVMObjectProtocol)]
    let quote_atom: Data
    let apply_atom: Data
    let unknown_op_handler: (Data, SExp) throws -> (Int, CLVMObjectProtocol)
    
    init(
        d: Dictionary<Data, (SExp) throws -> (Int, CLVMObjectProtocol)>,
        quote_atom: Data,
        apply_atom: Data,
        unknown_op_handler: ((Data, CLVMObjectProtocol) throws -> (Int, CLVMObjectProtocol))? = nil)
    {
        self.d = d
        
        // `quote_atom` and `apply_atom` must be set
        // `unknown_op_handler` has a default implementation
        // We do not check if quote and apply are distinct
        // We do not check if the opcode values for quote and apply exist in the passed-in dict
        self.quote_atom = quote_atom
        self.apply_atom = apply_atom
        if unknown_op_handler != nil {
            self.unknown_op_handler = unknown_op_handler!
        }
        else {
            self.unknown_op_handler = default_unknown_op
        }
    }
    
    subscript(op: Data) -> ((SExp) throws -> (Int, CLVMObjectProtocol))? {
        return d[op]
    }
    
    func call(op: Data, arguments: CLVMObjectProtocol) throws -> (Int, CLVMObjectProtocol) {
        let f = self.d[op]
        if f == nil {
            return try self.unknown_op_handler(op, SExp(obj: arguments))
        }
        else {
            return try f!(SExp(obj: arguments))
        }
    }
}

let QUOTE_ATOM = KEYWORD_TO_ATOM["q"]!
let APPLY_ATOM = KEYWORD_TO_ATOM["a"]!


let all_ops = core_ops.merging(more_ops) { (core_op, _) in core_op }
public let OPERATOR_LOOKUP = OperatorDict(
    d: operators_for_module(
        keyword_to_atom: KEYWORD_TO_ATOM,
        mod: all_ops,
        op_name_lookup: OP_REWRITE),
    quote_atom: QUOTE_ATOM,
    apply_atom: APPLY_ATOM
)
