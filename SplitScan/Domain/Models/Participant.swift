import Foundation

struct Participant: Codable, Hashable, Identifiable, Sendable {
        
    var colorHex: String
    var id: UUID
    var name: String
    var paidAt: Date?

    init(
        colorHex: String = "#2563EB",
        id: UUID = UUID(),
        name: String,
        paidAt: Date? = nil
    ) {
        self.colorHex = colorHex
        self.id = id
        self.name = name
        self.paidAt = paidAt
    }

    static let participantPalette: [String] = [
        "#EC4899", // Pink
        "#FACC15", // Yellow
        "#F97316", // Orange
        "#DC2626", // Red
        "#22C55E", // Bright Green
        "#166534", // Forest Green
        "#38BDF8", // Sky Blue
        "#2563EB", // Sapphire Blue
        "#9333EA", // Purple
        "#14B8A6", // Teal
        "#A16207", // Brown
        "#9CA3AF", // Gray
        "#000000", // Black
    ]

    static func nextAvailableColor(usedColors: Set<String>) -> String {
        for color in participantPalette where !usedColors.contains(color) {
            return color
        }

        return participantPalette.randomElement() ?? "#2563EB"
    }

}
