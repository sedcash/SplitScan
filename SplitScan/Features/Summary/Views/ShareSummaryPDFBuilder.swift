import SwiftUI
import UIKit

enum ShareSummaryPDFBuilder {
    @MainActor
    static func makePDF(
        receipt: Receipt,
        breakdowns: [ParticipantBreakdown],
        fileName: String = "receipt-summary.pdf"
    ) throws -> URL {
        let contentView = SummaryShareContentView(
            receipt: receipt,
            breakdowns: breakdowns
        )
        .frame(width: 700)
        .background(Color(.systemGray6))

        let renderer = ImageRenderer(content: contentView)
        renderer.scale = 2

        guard let image = renderer.uiImage else {
            throw CocoaError(.fileWriteUnknown)
        }

        return try SharePDFBuilder.makePDF(from: image, fileName: fileName)
    }
}
