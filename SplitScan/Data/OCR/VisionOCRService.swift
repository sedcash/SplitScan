import UIKit
import Vision

final class VisionOCRService: OCRService {
    
    func recognizeText(in image: UIImage) async throws -> OCRResult {
        guard let cgImage = image.cgImage else {
            return OCRResult(fullText: "", lines: [])
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let observations = (request.results as? [VNRecognizedTextObservation]) ?? []

                let tokens: [OCRToken] = observations.compactMap { observation in
                    guard let candidate = observation.topCandidates(1).first else {
                        return nil
                    }

                    return OCRToken(
                        text: candidate.string,
                        boundingBox: observation.boundingBox
                    )
                }

                let lines = Self.groupTokensIntoLines(tokens)

                continuation.resume(
                    returning: OCRResult(
                        fullText: lines.joined(separator: "\n"),
                        lines: lines
                    )
                )
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            do {
                try VNImageRequestHandler(cgImage: cgImage).perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

private struct OCRToken {
    let text: String
    let boundingBox: CGRect
}

private extension VisionOCRService {
    
    static func groupTokensIntoLines(_ tokens: [OCRToken]) -> [String] {
        guard !tokens.isEmpty else { return [] }

        // Vision bounding boxes are normalized [0,1].
        // Group tokens whose vertical midpoints are close enough to be on the same row.
        let sorted = tokens.sorted {
            let y0 = $0.boundingBox.midY
            let y1 = $1.boundingBox.midY

            if abs(y0 - y1) > 0.015 {
                return y0 > y1
            } else {
                return $0.boundingBox.minX < $1.boundingBox.minX
            }
        }

        var rows: [[OCRToken]] = []

        for token in sorted {
            if let lastIndex = rows.indices.last {
                let referenceY = averageMidY(for: rows[lastIndex])
                if abs(token.boundingBox.midY - referenceY) < 0.02 {
                    rows[lastIndex].append(token)
                } else {
                    rows.append([token])
                }
            } else {
                rows.append([token])
            }
        }

        return rows
            .map { row in
                row.sorted { $0.boundingBox.minX < $1.boundingBox.minX }
                    .map(\.text)
                    .joined(separator: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { !$0.isEmpty }
    }

    static func averageMidY(for row: [OCRToken]) -> CGFloat {
        let total = row.reduce(CGFloat.zero) { $0 + $1.boundingBox.midY }
        return total / CGFloat(row.count)
    }
}
