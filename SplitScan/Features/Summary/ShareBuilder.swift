import SwiftUI
import UIKit

enum ShareTextBuilder {
    static func make(receipt: Receipt, breakdowns: [ParticipantBreakdown]) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        var lines: [String] = []
        lines.append(receipt.merchantName)
        lines.append(formatter.string(from: receipt.date))
        lines.append("")

        for breakdown in breakdowns {
            lines.append("\(breakdown.participant.name): \(breakdown.total.formatted())")
        }

        lines.append("")
        lines.append("Total Bill: \(receipt.totals.grandTotal.formatted())")

        return lines.joined(separator: "\n")
    }
}

enum ShareImageBuilder {
    static func makePNG(
        from image: UIImage,
        fileName: String = "receipt-summary.png"
    ) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        guard let data = image.pngData() else {
            throw CocoaError(.fileWriteUnknown)
        }

        try data.write(to: url, options: .atomic)
        return url
    }
}

enum SharePDFBuilder {
    static func makePDF(
        from image: UIImage,
        fileName: String = "receipt-summary.pdf"
    ) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        try renderer.writePDF(to: url) { context in
            let imageSize = image.size
            let availableRect = pageRect.insetBy(dx: 24, dy: 24)

            let scale = min(
                availableRect.width / imageSize.width,
                availableRect.height / imageSize.height
            )

            let fittedSize = CGSize(
                width: imageSize.width * scale,
                height: imageSize.height * scale
            )

            let drawRect = CGRect(
                x: availableRect.minX + (availableRect.width - fittedSize.width) / 2,
                y: availableRect.minY,
                width: fittedSize.width,
                height: fittedSize.height
            )

            context.beginPage()
            image.draw(in: drawRect)
        }

        return url
    }
}
