import Foundation

enum ReceiptDetailsModalDestination: Identifiable, Equatable {
    case camera
    case imagePreview(path: String)

    var id: String {
        switch self {
        case .camera:
            return "camera"
        case .imagePreview(let path):
            return "imagePreview-\(path)"
        }
    }
}
