import Foundation

/// A condition of a coin spend
///
/// The generator program returns a list of coin spends with the following structure:
///```
/// (<coin-parent-id> <coin-puzzle-hash> <coin-amount> (CONDITION-LIST ...) ... )
///```
/// where ... represents possible extra fields that are currently ignored.
///
/// `CONDITION-LIST` lists all the conditions for the spend, including `CREATE_COIN`:
///```
/// (<condition-opcode> <arg1> <arg2> ...)
///```
/// Conditions have different numbers and types of arguments. For example:
/// ```
/// ((<coin-parent-id> <coind-puzzle-hash> <coin-amount> (
///  (
///    (CREATE_COIN <puzzle-hash> <amount>)
///    (ASSERT_HEIGHT_ABSOLUTE <height>)
///  )
/// )))
/// ```
enum Condition {
    case AggSigUnsafe((pubkey: SExp, message: SExp)) // message (<= 1024 bytes)
    case AggSigMe((pubkey: SExp, message: SExp)) // message (<= 1024 bytes)

    // puzzle hash and hint are 32 bytes
    case CreateCoin((puzzle_hash: SExp, amount: UInt64, hint: SExp?))

    case ReserveFee(amount: UInt64)

    case CreateCoinAnnouncement(message: SExp) // message (<= 1024 bytes)
    case CreatePuzzleAnnouncement(message: SExp) // message (<= 1024 bytes)

    case AssertCoinAnnouncement(announcement_id: SExp) // announcement_id (hash, 32 bytes)
    case AssertPuzzleAnnouncement(announcement_id: SExp) // announcement_id (hash, 32 bytes)

    case AssertMyCoinId(id: SExp) // (id hash, 32 bytes)
    case AssertMyParentId(id: SExp) // (id hash, 32 bytes)
    case AssertMyPuzzlehash(id: SExp) // (id hash, 32 bytes)

    case AssertMyAmount(amount: UInt64)

    case AssertSecondsRelative(seconds: UInt64)
    case AssertSecondsAbsolute(seconds: UInt64)

    case AssertHeightRelative(height: UInt32)
    case AssertHeightAbsolute(height: UInt32)

    // this means the condition is unconditionally true and can be skipped
    case Skip
}

public struct Spend {
    public let coin_id: Data
    public let puzzle_hash: Data
    public let height_relative: UInt32?
    public let seconds_relative: UInt64
    public let create_coin: [(Data, UInt64, Data)] // Vec<(PyObject, u64, PyObject)>
    public let agg_sig_me: [(Data, Data)] // Vec<(PyObject, PyObject)>,
}

public struct SpendBundleConditions {
    public let spends: [Spend]
    public let reserve_fee: UInt64
    // the highest height/time conditions (i.e. most strict)
    public let height_absolute: UInt32
    public let seconds_absolute: UInt64
    // Unsafe Agg Sig conditions (i.e. not tied to the spend generating it)
    public let agg_sig_unsafe: [(Data, Data)] // Vec<(PyObject, PyObject)>
    public var cost: UInt64
}

// This function parses, and validates aspects of, the above structure and
// returns a list of all spends, along with all conditions, organized by
// condition op-code
func parse_spends(
    spends: CLVMObjectProtocol, //NodePtr,
    max_cost: UInt64,//Cost,
    flags: UInt32
) -> Result<SpendBundleConditions, ValidationErr> {
    let ret = SpendBundleConditions(
        spends: [],
        reserve_fee: 0,
        height_absolute: 0,
        seconds_absolute: 0,
        agg_sig_unsafe: [],
        cost: 0
    )
    #warning("not implemented")
    print("\nparse_spends not implemented\n")
    return .success(ret)
}
