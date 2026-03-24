import UIKit

protocol OCRService {
    func recognizeText(in image: UIImage) async throws -> OCRResult
}
