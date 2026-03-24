import Foundation

enum TipPolicy: Codable, Hashable, Sendable {
    
    case proportional
    case equal
    case onePerson(participantID: UUID)

    var title: String {
        switch self {
        case .proportional:
            return "Proportional"
        case .equal:
            return "Equal"
        case .onePerson:
            return "One Person"
        }
    }

}
