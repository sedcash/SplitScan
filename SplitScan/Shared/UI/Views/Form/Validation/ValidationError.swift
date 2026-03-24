import Foundation

struct ValidationError: Equatable, Identifiable {
    let field: EditFormField
    let message: String
    
    var id: String {
        "\(field)-\(message)"
    }
}
