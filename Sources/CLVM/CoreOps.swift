let core_ops = [
    "op_if": op_if,
    "op_cons": op_cons,
    "op_first": op_first,
    "op_rest": op_rest,
    "op_listp": op_listp,
    "op_raise": op_raise,
    "op_eq": op_eq
]

func op_if(args: SExp) throws -> (Int, SExp) {
    if try args.list_len() != 3 {
        throw(EvalError(message: "i takes exactly 3 arguments", sexp: args))
    }
    let r = try args.rest()
    if try args.first().nullp() {
        return (IF_COST, try r.rest().first())
    }
    return (IF_COST, try r.first())
}

func op_cons(args: SExp) throws -> (Int, SExp) {
    if try args.list_len() != 2 {
        throw(EvalError(message: "c takes exactly 2 arguments", sexp: args))
    }
    return (CONS_COST, try args.first().cons(right: .sexp(args.rest().first())))
}

func op_first(args: SExp) throws -> (Int, SExp) {
    if try args.list_len() != 1 {
        throw(EvalError(message: "f takes exactly 1 argument", sexp: args))
    }
    return (FIRST_COST, try args.first().first())
}

func op_rest(args: SExp) throws -> (Int, SExp) {
    if try args.list_len() != 1 {
        throw(EvalError(message: "r takes exactly 1 argument", sexp: args))
    }
    return (REST_COST, try args.first().rest())
}

func op_listp(args: SExp) throws -> (Int, SExp) {
    if try args.list_len() != 1 {
        throw(EvalError(message: "l takes exactly 1 argument", sexp: args))
    }
    return (LISTP_COST, try args.first().listp() ? SExp.true_sexp : SExp.false_sexp)
}

func op_raise(args: SExp) throws -> (Int, SExp) {
    throw(EvalError(message: "clvm raise", sexp: args))
}

func op_eq(args: SExp) throws -> (Int, SExp) {
    if try args.list_len() != 2 {
        throw(EvalError(message: "= takes exactly 2 arguments", sexp: args))
    }
    let a0 = try args.first()
    let a1 = try args.rest().first()
    if (a0.pair != nil) || (a1.pair != nil) {
        throw(EvalError(message: "= on list", sexp: (a0.pair != nil) ? a0 : a1))
    }
    let b0 = a0.atom!
    let b1 = a1.atom!
    var cost = EQ_BASE_COST
    cost += (b0.count + b1.count) * EQ_COST_PER_BYTE
    return (cost, (b0 == b1 ? SExp.true_sexp : SExp.false_sexp))
}
