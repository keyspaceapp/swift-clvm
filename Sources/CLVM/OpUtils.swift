import Foundation

func operators_for_dict(keyword_to_atom: [String: Data], op_dict: [String : (SExp) throws -> (Int, SExp)], op_name_lookup: [String: String] = [:]) -> [Data: (SExp) throws -> (Int, CLVMObjectProtocol)] {
    var d: [Data: (SExp) throws -> (Int, CLVMObjectProtocol)] = [:]
    for op in keyword_to_atom.keys {
        let op_name = "op_\(op_name_lookup[op, default: op])"
        let op_f = op_dict[op_name]
        if op_f != nil {
            d[keyword_to_atom[op]!] = op_f
        }
    }
    return d
}

func operators_for_module(
    keyword_to_atom: [String: Data],
    mod: [String : (SExp) throws -> (Int, SExp)],
    op_name_lookup: [String: String] = [:]
) -> [Data: (SExp) throws -> (Int, CLVMObjectProtocol)] {
    return operators_for_dict(
        keyword_to_atom: keyword_to_atom,
        op_dict: mod,
        op_name_lookup: op_name_lookup)
}
