import Foundation
import CryptoKit
import BigInt
import BLS

let more_ops = [
    "op_sha256": op_sha256,
    "op_add": op_add,
    "op_subtract": op_subtract,
    "op_multiply": op_multiply,
    "op_divmod": op_divmod,
    "op_div": op_div,
    "op_gr": op_gr,
    "op_gr_bytes": op_gr_bytes,
    "op_pubkey_for_exp": op_pubkey_for_exp,
    "op_point_add": op_point_add,
    "op_strlen": op_strlen,
    "op_substr": op_substr,
    "op_concat": op_concat,
    "op_ash": op_ash,
    "op_lsh": op_lsh,
    "op_logand": op_logand,
    "op_logior": op_logior,
    "op_logxor": op_logxor,
    "op_lognot": op_lognot,
    "op_not": op_not,
    "op_any": op_any,
    "op_all": op_all,
    "op_softfork": op_softfork
]

func malloc_cost(cost: Int, atom: SExp) -> (Int, SExp) {
    return (cost + atom.atom!.count * MALLOC_COST_PER_BYTE, atom)
}

func op_sha256(args: SExp) throws -> (Int, SExp) {
    var cost = SHA256_BASE_COST
    var arg_len = 0
    var h = SHA256()
    for arg in args.as_iter() {
        guard let atom = arg.atom else {
            throw(EvalError(message: "sha256 on list", sexp: arg))
        }
        arg_len += atom.count
        cost += SHA256_COST_PER_ARG
        h.update(data: atom)
    }
    cost += arg_len * SHA256_COST_PER_BYTE
    return malloc_cost(cost: cost, atom: try SExp.to(v: .bytes(Data(h.finalize()))))
}

func args_as_ints(op_name: String, args: SExp) throws -> [(BigInt, Int)] {
    try args.as_iter().map({ arg in
        if arg.pair != nil {
            throw(EvalError(message: "\(op_name) requires int args", sexp: arg))
        }
        return (arg.as_int(), arg.atom!.count)
    })
}


func args_as_int32(op_name: String, args: SExp) throws -> [Int32] {
    var ints: [Int32] = []
    for arg in args.as_iter() {
        if arg.pair != nil {
            throw(EvalError(message: "\(op_name) requires int32 args", sexp: arg))
        }
        if arg.atom!.count > 4 {
            throw(EvalError(message: "\(op_name) requires int32 args (with no leading zeros)", sexp: arg))
        }
        ints.append(Int32(arg.as_int()))
    }
    return ints
}

func args_as_int_list(op_name: String, args: SExp, count: Int) throws -> [(BigInt, Int)] {
    let int_list = try args_as_ints(op_name: op_name, args: args)
    if int_list.count != count {
        let plural = count != 1 ? "s" : ""
        throw(EvalError(message: "\(op_name) takes exactly \(count) argument\(plural)", sexp: args))
    }
    return int_list
}

func args_as_bools(op_name: String, args: SExp) -> [SExp] {
    var bools: [SExp] = []
    for arg in args.as_iter() {
        let v = arg.atom
        if v == Data() {
            bools.append(SExp.false_sexp)
        }
        else {
            bools.append(SExp.true_sexp)
        }
    }
    return bools
}

func args_as_bool_list(op_name: String, args: SExp, count: Int) throws -> [SExp] {
    let bool_list = args_as_bools(op_name: op_name, args: args)
    if bool_list.count != count {
        let plural = count != 1 ? "s" : ""
        throw(EvalError(message: "\(op_name) takes exactly \(count) argument\(plural)", sexp: args))
    }
    return bool_list
}

func op_add(args: SExp) throws -> (Int, SExp) {
    var total: BigInt = 0
    var cost = ARITH_BASE_COST
    var arg_size = 0
    for (r, l) in try args_as_ints(op_name: "+", args: args) {
        total += r
        arg_size += l
        cost += ARITH_COST_PER_ARG
    }
    cost += arg_size * ARITH_COST_PER_BYTE
    return malloc_cost(cost: cost, atom: try SExp.to(v: .int(total)))
}

func op_subtract(args: SExp) throws -> (Int, SExp) {
    var cost = ARITH_BASE_COST
    if args.nullp() {
        return malloc_cost(cost: cost, atom: try SExp.to(v: .int(0)))
    }
    var sign: BigInt = 1
    var total: BigInt = 0
    var arg_size = 0
    for (r, l) in try args_as_ints(op_name: "-", args: args) {
        total += sign * r
        sign = -1
        arg_size += l
        cost += ARITH_COST_PER_ARG
    }
    cost += arg_size * ARITH_COST_PER_BYTE
    return malloc_cost(cost: cost, atom: try SExp.to(v: .int(total)))
}

func op_multiply(args: SExp) throws -> (Int, SExp) {
    var cost = MUL_BASE_COST
    let operands = try args_as_ints(op_name: "*", args: args)
    if operands.isEmpty {
        return malloc_cost(cost: cost, atom: try SExp.to(v: .int(1)))
    }
    var (v, vs) = operands.first!

    for (r, rs) in operands {
        cost += MUL_COST_PER_OP
        cost += (rs + vs) * MUL_LINEAR_COST_PER_BYTE
        cost += (rs * vs) / MUL_SQUARE_COST_PER_BYTE_DIVIDER
        v = v * r
        vs = limbs_for_int(v: v)
    }
    return malloc_cost(cost: cost, atom: try SExp.to(v: .int(v)))
}

func op_divmod(args: SExp) throws -> (Int, SExp) {
    var cost = DIVMOD_BASE_COST
    let int_list = try args_as_int_list(op_name: "divmod", args: args, count: 2)
    let (i0, l0) = int_list[0]
    let (i1, l1) = int_list[1]
    if i1 == 0 {
        throw(EvalError(message: "divmod with 0", sexp: try SExp.to(v: .int(i0))))
    }
    cost += (l0 + l1) * DIVMOD_COST_PER_BYTE
    
    var q = i0 / i1
    #warning("hacky, possibly incorrect")
    let r = (i0 % i1 + i1) % i1 // hack to match python modulus behavior
    if (q <= 0 && r != 0 && i0.sign != i1.sign) {
        q -= 1
    }
    
    let q1 = try SExp.to(v: .int(q))
    let r1 = try SExp.to(v: .int(r))
    cost += (q1.atom!.count + r1.atom!.count) * MALLOC_COST_PER_BYTE
    return (cost, try SExp.to(v: .tuple((.int(q), .int(r)))))
}

func op_div(args: SExp) throws -> (Int, SExp) {
    var cost = DIV_BASE_COST
    let int_list = try args_as_int_list(op_name: "/", args: args, count: 2)
    let (i0, l0) = int_list[0]
    let (i1, l1) = int_list[1]
    if i1 == 0 {
        throw(EvalError(message: "div with 0", sexp: try SExp.to(v: .int(i0))))
    }
    cost += (l0 + l1) * DIV_COST_PER_BYTE
    var (q, r) = i0.quotientAndRemainder(dividingBy: i1)

    // this is to preserve a buggy behavior from the initial implementation
    // of this operator.
    if q == -1 && r != 0 {
        q += 1
    }

    return malloc_cost(cost: cost, atom: try SExp.to(v: .int(q)))
}

func op_gr(args: SExp) throws -> (Int, SExp) {
    let int_list = try args_as_int_list(op_name: ">", args: args, count: 2)
    let (i0, l0) = int_list[0]
    let (i1, l1) = int_list[1]
    var cost = GR_BASE_COST
    cost += (l0 + l1) * GR_COST_PER_BYTE
    return (cost, i0 > i1 ? SExp.true_sexp : SExp.false_sexp)
}

func op_gr_bytes(args: SExp) throws -> (Int, SExp) {
    let arg_list = args.as_iter()
    if arg_list.count != 2 {
        throw(EvalError(message: ">s takes exactly 2 arguments", sexp: args))
    }
    
    let a0 = arg_list[0]
    let a1 = arg_list[1]
    if a0.pair != nil || a1.pair != nil {
        throw(EvalError(message: ">s on list", sexp: a0.pair != nil ? a0 : a1))
    }
    
    let b0 = a0.atom!
    let b1 = a1.atom!
    var cost = GRS_BASE_COST
    cost += (b0.count + b1.count) * GRS_COST_PER_BYTE
    
    return (cost, b0 > b1 ? SExp.true_sexp : SExp.false_sexp)
}

private func > (lhs: Data, rhs: Data) -> Bool {
    var index = 0
    while index < lhs.count && index < rhs.count {
        if lhs[index] != rhs[index] {
            return lhs[index] > rhs[index]
        }
        index += 1
    }
    // Common prefix, shorter one comes first
    return lhs.count > rhs.count
}

func op_pubkey_for_exp(args: SExp) throws -> (Int, SExp) {
    let int_list = try args_as_int_list(op_name: "pubkey_for_exp", args: args, count: 1)
    var i0 = int_list[0].0
    let l0 = int_list[0].1
    let mod_value = BigInt("73EDA753299D7D483339D80809A1D80553BDA402FFFE5BFEFFFFFFFF00000001", radix: 16)!
    i0 =  i0 % mod_value
    if i0 < 0 {
        // hack to get python % behavior with swift
        i0 += mod_value
    }
    let exponent = PrivateKey(bytes: i0.to_bytes(byte_count: 32, endian: .big))! //i0.to_bytes(32, "big"))
    do {
        #warning("why not just g1 directly")
        let r = try SExp.to(v: .bytes(exponent.get_g1()!.get_bytes()))
        var cost = PUBKEY_BASE_COST
        cost += l0 * PUBKEY_COST_PER_BYTE
        return malloc_cost(cost: cost, atom: r)
    }
    catch {
        throw(EvalError(message: "problem in op_pubkey_for_exp: \(error)", sexp: args))
    }
}

func op_point_add(items: SExp) throws -> (Int, SExp) {
    var cost = POINT_ADD_BASE_COST
    var p = G1Element()

    for item in items.as_iter() {
        if item.pair != nil {
            throw(EvalError(message: "point_add on list", sexp: item))
        }
        do {
            #warning("hack until c++ exceptions are handled in swift")
            guard item.atom != nil && item.atom!.count == G1Element.size() else {
                throw(ValueError("Length of bytes object not equal to G1Element::SIZE"))
            }
            p = p.add(G1Element.from_bytes(item.atom!).get_bytes())
            cost += POINT_ADD_COST_PER_ARG
        } catch let error as ValueError {
            throw(EvalError(message: "point_add expects blob, got \(item): \(error.message!)", sexp: items))
        }
    }
    return malloc_cost(cost: cost, atom: try SExp.to(v: .g1(p)))
}

func op_strlen(args: SExp) throws -> (Int, SExp) {
    if try args.list_len() != 1 {
        throw(EvalError(message: "strlen takes exactly 1 argument", sexp: args))
    }
    let a0 = try args.first()
    if (a0.pair != nil) {
        throw(EvalError(message: "strlen on list", sexp: a0))
    }
    let size = a0.atom!.count
    let cost = STRLEN_BASE_COST + size * STRLEN_COST_PER_BYTE
    return malloc_cost(cost: cost, atom: try SExp.to(v: .int(BigInt(size))))
}

func op_substr(args: SExp) throws -> (Int, SExp) {
    let arg_count = try args.list_len()
    if [2, 3].firstIndex(of: arg_count) == nil {
        throw(EvalError(message: "substr takes exactly 2 or 3 arguments", sexp: args))
    }
    let a0 = try args.first()
    if a0.pair != nil {
        throw(EvalError(message: "substr on list", sexp: a0))
    }
    
    let s0 = Data(a0.atom!)
    
    let i1: Int32
    let i2: Int32
    if arg_count == 2 {
        i1 = try args_as_int32(op_name: "substr", args: args.rest())[0]
        i2 = Int32(s0.count)
    }
    else {
        let args = try args_as_int32(op_name: "substr", args: args.rest())
        i1 = args[0]
        i2 = args[1]
    }

    if i2 > s0.count || i2 < i1 || i2 < 0 || i1 < 0 {
        throw(EvalError(message: "invalid indices for substr", sexp: args))
    }
    let s = s0[i1..<i2]
    let cost = 1
    return (cost, try SExp.to(v: .bytes(s)))
}

func op_concat(args: SExp) throws -> (Int, SExp) {
    var cost = CONCAT_BASE_COST
    var r = Data()
    for arg in args.as_iter(){
        if arg.pair != nil {
            throw(EvalError(message: "concat on list", sexp: arg))
        }
        r += arg.atom!
        cost += CONCAT_COST_PER_ARG
    }
    cost += r.count * CONCAT_COST_PER_BYTE
    return malloc_cost(cost: cost, atom: try SExp.to(v: .bytes(r)))
}

func op_ash(args: SExp) throws -> (Int, SExp) {
    throw(EvalError(message: "op_ash not implemented", sexp: SExp(obj: CLVMObject(v: .string("")))))
}

func op_lsh(args: SExp) throws -> (Int, SExp) {
    throw(EvalError(message: "op_lsh not implemented", sexp: SExp(obj: CLVMObject(v: .string("")))))
}

func binop_reduction(op_name: String, initial_value: BigInt, args: SExp, op_f: (BigInt, BigInt) -> BigInt) throws -> (Int, SExp) {
    var total = initial_value
    var arg_size = 0
    var cost = LOG_BASE_COST
    for (r, l) in try args_as_ints(op_name: op_name, args: args) {
        total = op_f(total, r)
        arg_size += l
        cost += LOG_COST_PER_ARG
    }
    cost += arg_size * LOG_COST_PER_BYTE
    return malloc_cost(cost: cost, atom: try SExp.to(v: .int(total)))
}

func op_logand(args: SExp) throws -> (Int, SExp) {
    func binop(a: BigInt, b: BigInt) -> BigInt {
        var a = a
        a &= b
        return a
    }

    return try binop_reduction(op_name: "logand", initial_value: -1, args: args, op_f: binop)
}

func op_logior(args: SExp) throws -> (Int, SExp) {
    func binop(a: BigInt, b: BigInt) -> BigInt {
        var a = a
        a |= b
        return a
    }
    return try binop_reduction(op_name: "logior", initial_value: 0, args: args, op_f: binop)
}

func op_logxor(args: SExp) throws -> (Int, SExp) {
    func binop(a: BigInt, b: BigInt) -> BigInt {
        var a = a
        a ^= b
        return a
    }
    
    return try binop_reduction(op_name: "logxor", initial_value: 0, args: args, op_f: binop)
}

func op_lognot(args: SExp) throws -> (Int, SExp) {
    let int_list = try args_as_int_list(op_name: "lognot", args: args, count: 1)
    let (i0, l0) = int_list[0]
    let cost = LOGNOT_BASE_COST + l0 * LOGNOT_COST_PER_BYTE
    return malloc_cost(cost: cost, atom: try SExp.to(v: .int(~i0)))
}

func op_not(args: SExp) throws -> (Int, SExp) {
    let bool_list = try args_as_bool_list(op_name: "not", args: args, count: 1)
    let i0 = bool_list[0]
    let r: SExp
    if i0.atom == Data() {
        r = SExp.true_sexp
    }
    else {
        r = SExp.false_sexp
    }
    let cost = BOOL_BASE_COST
    return (cost, try SExp.to(v: .sexp(r)))
}

func op_any(args: SExp) throws -> (Int, SExp) {
    let items = args_as_bools(op_name: "any", args: args)
    let cost = BOOL_BASE_COST + items.count * BOOL_COST_PER_ARG
    var r = SExp.false_sexp
    for v in items {
        if v.atom != Data() {
            r = SExp.true_sexp
            break
        }
    }
    return (cost, try SExp.to(v: .sexp(r)))
}


func op_all(args: SExp) throws -> (Int, SExp) {
    let items = args_as_bools(op_name: "all", args: args)
    let cost = BOOL_BASE_COST + items.count * BOOL_COST_PER_ARG
    var r = SExp.true_sexp
    for v in items {
        if v.atom == Data() {
            r = SExp.false_sexp
            break
        }
    }
    return (cost, try SExp.to(v: .sexp(r)))
}

func op_softfork(args: SExp) throws -> (Int, SExp) {
    throw(EvalError(message: "op_softfork not implemented", sexp: SExp(obj: CLVMObject(v: .string("")))))
}
