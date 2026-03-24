import Foundation

protocol SplitCalculating {
    func calculate(receipt: Receipt) -> [ParticipantBreakdown]
}
