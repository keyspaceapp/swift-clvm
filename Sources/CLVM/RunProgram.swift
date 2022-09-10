import Foundation
import BigInt

// indirect enum to handle recursive type
enum OpCallable {
    indirect case op((inout OpStackType, inout ValStackType) throws -> Int)
}

typealias ValStackType = [SExp]
typealias OpStackType = [OpCallable]

func to_pre_eval_op(pre_eval_f: @escaping ((SExp, SExp) -> ((SExp) -> Void)?), to_sexp_f: @escaping (CastableType) throws -> SExp) -> ((inout OpStackType, inout ValStackType) throws -> Void) {
    func my_pre_eval_op(op_stack: inout OpStackType, value_stack: inout ValStackType) throws {
        let v = try to_sexp_f(.sexp(value_stack.last!))
        let context = pre_eval_f(try v.first(), try v.rest())
        if context != nil {

            func invoke_context_op(
                op_stack: inout OpStackType, value_stack: inout ValStackType
            ) throws -> Int {
                context!(try to_sexp_f(.sexp(value_stack.last!)))
                return 0
            }

            op_stack.append(.op(invoke_context_op))
        }
    }

    return my_pre_eval_op
}

func msb_mask(byte: UInt8) -> Int {
    var byte = Int(byte)
    byte |= byte >> 1
    byte |= byte >> 2
    byte |= byte >> 4
    return (byte + 1) >> 1
}

func traverse_path(sexp: SExp, env: SExp) throws -> (Int, SExp) {
    var cost = PATH_LOOKUP_BASE_COST
    cost += PATH_LOOKUP_COST_PER_LEG
    if sexp.nullp() {
        return (cost, SExp.null())
    }
    
    let b = sexp.atom!

    var end_byte_cursor = 0
    while end_byte_cursor < b.count && b[end_byte_cursor] == 0 {
        end_byte_cursor += 1
    }

    cost += end_byte_cursor * PATH_LOOKUP_COST_PER_ZERO_BYTE
    if end_byte_cursor == b.count {
        return (cost, SExp.null())
    }

    // create a bitmask for the most significant *set* bit
    // in the last non-zero byte
    let end_bitmask = msb_mask(byte: b[end_byte_cursor])

    var byte_cursor = b.count - 1
    var bitmask = 0x01
    var env = env
    while byte_cursor > end_byte_cursor || bitmask < end_bitmask {
        if env.pair == nil {
            throw(EvalError(message: "path into atom", sexp: env))
        }
        if ((Int(b[byte_cursor]) & bitmask) != 0) {
            env = try env.rest()
        }
        else {
            env = try env.first()
        }
        cost += PATH_LOOKUP_COST_PER_LEG
        bitmask <<= 1
        if bitmask == 0x100 {
            byte_cursor -= 1
            bitmask = 0x01
        }
    }
    return (cost, env)
}

public func run_program(
    program: CLVMObjectProtocol,
    args: CLVMObjectProtocol,
    operator_lookup: OperatorDict,
    max_cost: Int? = nil,
    pre_eval_f: ((SExp, SExp) -> ((SExp) -> Void))? = nil
) throws -> (Int, SExp) {

    let program = try SExp.to(v: .object(program))
    let pre_eval_op: ((inout OpStackType, inout ValStackType) throws -> Void)?
    if (pre_eval_f != nil) {
        pre_eval_op = to_pre_eval_op(pre_eval_f: pre_eval_f!, to_sexp_f: SExp.to)
    }
    else {
        pre_eval_op = nil
    }

    func swap_op(op_stack: inout OpStackType, value_stack: inout ValStackType) -> Int {
        let v2 = value_stack.popLast()!
        let v1 = value_stack.popLast()!
        value_stack.append(v2)
        value_stack.append(v1)
        return 0
    }

    func cons_op(op_stack: inout OpStackType, value_stack: inout ValStackType) throws -> Int {
        let v1 = value_stack.popLast()!
        let v2 = value_stack.popLast()!
        value_stack.append(try v1.cons(right: .sexp(v2)))
        return 0
    }

    // Pop the top value and treat it as a (program, args) pair, and manipulate
    // the op & value stack to evaluate all the arguments and apply the operator.
    func eval_op(op_stack: inout OpStackType, value_stack: inout ValStackType) throws -> Int {
        if pre_eval_op != nil {
            try pre_eval_op!(&op_stack, &value_stack)
        }

        let pair = value_stack.popLast()!
        let program = try pair.first()
        let args = try pair.rest()

        // put a bunch of ops on op_stack

        if program.pair == nil {
            // program is an atom
            let (cost, r) = try traverse_path(sexp: program, env: args)
            value_stack.append(r)
            return cost
        }

        let cur_operator = try program.first()
        if cur_operator.pair != nil {
            let (new_operator, must_be_nil) = cur_operator.as_pair()!
            if (new_operator.pair != nil) || must_be_nil.atom != Data() {
                throw(EvalError(message: "in ((X)...) syntax X must be lone atom", sexp: program))
            }
            let new_operand_list = try program.rest()
            value_stack.append(new_operator)
            value_stack.append(new_operand_list)
            op_stack.append(.op(apply_op))
            return APPLY_COST
        }

        let op = cur_operator.atom
        var operand_list = try program.rest()
        if op == operator_lookup.quote_atom {
            value_stack.append(operand_list)
            return QUOTE_COST
        }

        op_stack.append(.op(apply_op))
        value_stack.append(cur_operator)
        while !operand_list.nullp() {
            let first = try operand_list.first()
            value_stack.append(try first.cons(right: .sexp(args)))
            op_stack.append(.op(cons_op))
            op_stack.append(.op(eval_op))
            op_stack.append(.op(swap_op))
            operand_list = try operand_list.rest()
        }
        value_stack.append(SExp.null())
        return 1
    }

    func apply_op(op_stack: inout OpStackType, value_stack: inout ValStackType) throws -> Int {
        let operand_list = value_stack.popLast()!
        let cur_operator = value_stack.popLast()!
        if cur_operator.pair != nil {
            throw(EvalError(message: "internal error", sexp: cur_operator))
        }

        let op = cur_operator.atom
        if op == operator_lookup.apply_atom {
            if try operand_list.list_len() != 2 {
                throw(EvalError(message: "apply requires exactly 2 parameters", sexp: operand_list))
            }
            let new_program = try operand_list.first()
            let new_args = try operand_list.rest().first()
            value_stack.append(try new_program.cons(right: .sexp(new_args)))
            op_stack.append(.op(eval_op))
            return APPLY_COST
        }

        let (additional_cost, r) = try operator_lookup.call(op: op!, arguments: operand_list)
        value_stack.append(SExp(obj: r))
        return additional_cost
    }

    var op_stack: OpStackType = [.op(eval_op)]
    var value_stack: ValStackType = [try program.cons(right: .object(args))]
    var cost: Int = 0

    while !op_stack.isEmpty {
        let f = op_stack.popLast()!
        switch f {
        case .op(let op):
            cost += try op(&op_stack, &value_stack)
        }
        if max_cost != nil && cost > max_cost! {
            throw(EvalError(message: "cost exceeded", sexp: try SExp.to(v: .int(BigInt(max_cost!)))))
        }
    }
    return (cost, value_stack.last!)
}

public func run_serialized_program(
    program: [UInt8],
    args: [UInt8],
    max_cost: UInt64, //Cost,
    flags: UInt32
) throws -> (Int, SExp) { // PyResult<Response> {
    #warning("hacky conversion")
    var program_iter = Data(program).makeIterator()
    var args_iter = Data(args).makeIterator()
    let program = try sexp_from_stream(f: &program_iter, to_sexp: SExp.to)  //SExp(obj: CLVMObject(v: .bytes(Data(program)))) // node_from_bytes(allocator, program)?;
    let args = try sexp_from_stream(f: &args_iter, to_sexp: SExp.to) //SExp(obj: CLVMObject(v: .bytes(Data(args)))) // node_from_bytes(allocator, args)?;

    return try run_program(program: program, args: args, operator_lookup: OPERATOR_LOOKUP, max_cost: Int(max_cost), pre_eval_f: nil)
}

public func deserialize_and_run_program2(
    program: [UInt8],
    args: [UInt8],
    quote_kw: UInt8,
    apply_kw: UInt8,
    opcode_lookup_by_name: [String: [UInt8]],
    max_cost: UInt64, //Cost,
    flags: UInt32
) throws -> (Int, SExp) { //(Cost, LazyNode) {
//    let mut allocator = Allocator::new();
    return try run_serialized_program(
        program: program,
        args: args,
        max_cost: max_cost,
        flags: flags
    )
}

