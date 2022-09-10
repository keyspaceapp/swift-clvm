import Foundation

func convert_spend_bundle_conds(
    sb: SpendBundleConditions
) -> SpendBundleConditions {
    var spends: [Spend] = []
    for s in sb.spends {
        spends.append(s)
    }

    var agg_sigs: [(Data, Data)] = []
    for (pk, msg) in sb.agg_sig_unsafe {
        agg_sigs.append((pk, msg))
    }

    return SpendBundleConditions(
        spends: spends,
        reserve_fee: sb.reserve_fee,
        height_absolute: sb.height_absolute,
        seconds_absolute: sb.seconds_absolute,
        agg_sig_unsafe: agg_sigs,
        cost: sb.cost
    )
}

// returns the cost of running the CLVM program along with conditions and the list of
// spends
public func run_generator2(
    program: [UInt8],
    args: [UInt8],
    max_cost: UInt64, //Cost,
    flags: UInt32
) throws -> Result<(UInt16?, SpendBundleConditions?), EvalError> {
    var program_iter = Data(program).makeIterator()
    var args_iter = Data(args).makeIterator()
    let program = try sexp_from_stream(f: &program_iter, to_sexp: SExp.to)
    let args = try sexp_from_stream(f: &args_iter, to_sexp: SExp.to)
    
    let (cost, node) = try run_program(program: program, args: args, operator_lookup: OPERATOR_LOOKUP, max_cost: Int(max_cost), pre_eval_f: nil)
    
    let r: Result<(ErrorCode?, SpendBundleConditions?), EvalError>
    // we pass in what's left of max_cost here, to fail early in case the
    // cost of a condition brings us over the cost limit
    switch parse_spends(spends: node, max_cost: max_cost - UInt64(cost), flags: flags) {
    case .failure(let error):
        return .success((error.error.rawValue, nil))
    case .success(var spend_bundle_conds):
        // the cost is only the cost of conditions, add the
        // cost of running the CLVM program here as well
        spend_bundle_conds.cost += UInt64(cost)
        r = .success((nil, spend_bundle_conds))
    }
    
    switch r {
    case .success(let (error, spend_bundle_conds)):
        if spend_bundle_conds != nil {
            // everything was successful
            return .success((nil, convert_spend_bundle_conds(sb: spend_bundle_conds!)))
        } else {
            // a validation error occurred
            #warning("probably incorrect")
            return .success((error?.rawValue, nil)) // Ok((error_code.map(|x| x.into()), None))
        }
    case .failure(let error):
        // a validation error occurred
        return .failure(error) // eval_err_to_pyresult(py, eval_err, allocator),
    }
}
