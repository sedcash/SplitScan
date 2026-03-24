import SwiftUI
import UIKit

enum ShareSummaryImageBuilder {
    @MainActor
    static func makeImage(
        receipt: Receipt,
        breakdowns: [ParticipantBreakdown]
    ) -> UIImage? {
        let view = ShareSummaryView(
            receipt: receipt,
            breakdowns: breakdowns
        )

        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        renderer.isOpaque = true

        return renderer.uiImage
    }
}
