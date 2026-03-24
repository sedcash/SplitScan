import Foundation

struct OCRResult: Sendable {
    var fullText: String
    var lines: [String]
}
