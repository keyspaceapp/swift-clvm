import Foundation

enum ErrorCode: UInt16 {
    case NegativeAmount
    case InvalidConditionOpcode
    case InvalidParentId
    case InvalidPuzzleHash
    case InvalidPubkey
    case InvalidMessage
    case InvalidCondition
    case InvalidCoinAmount
    case InvalidCoinAnnouncement
    case InvalidPuzzleAnnouncement
    case AssertHeightAbsolute
    case AssertHeightRelative
    case AssertSecondsAbsolute
    case AssertSecondsRelative
    case AssertMyAmountFailed
    case AssertMyPuzzlehashFailed
    case AssertMyParentIdFailed
    case AssertMyCoinIdFailed
    case AssertPuzzleAnnouncementFailed
    case AssertCoinAnnouncementFailed
    case ReserveFeeConditionFailed
    case DuplicateOutput
    case DoubleSpend
    case CostExceeded
}

public struct ValidationErr: Error {
    let value: CLVMObjectProtocol
    let error: ErrorCode
}
