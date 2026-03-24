import Foundation
import SwiftUI

enum PaymentStatus: String, Hashable, Sendable {
    case unpaid
    case partial
    case paid
    
    var color: Color {
        switch self {
        case .paid:
            Color.green
        case .unpaid:
            Color.red
        case .partial:
            Color.yellow
        }
    }
}
