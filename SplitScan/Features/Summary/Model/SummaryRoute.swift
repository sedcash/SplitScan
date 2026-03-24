import Foundation

enum SummaryOverlay: Hashable, Identifiable {
    
    case addPayment(participantID: UUID)
    case paymentHistory(participantID: UUID)
    case tipEditor

    var id: String {
        switch self {
        case .addPayment(let participantID):
            "addPayment_\(participantID.uuidString)"
        case .paymentHistory(let participantID):
            "paymentHistory_\(participantID.uuidString)"
        case .tipEditor:
            "tipEditor"
        }
    }
}
