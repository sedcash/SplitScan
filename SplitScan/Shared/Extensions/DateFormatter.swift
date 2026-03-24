import Foundation

extension DateFormatter {
    
    static let paymentDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy 'at' h:mm a"
        return formatter
    }()
    
}
