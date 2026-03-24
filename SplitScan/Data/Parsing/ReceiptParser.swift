import Foundation

protocol ReceiptParsing {
    func parse(ocr: OCRResult, currencyCode: String) -> Receipt
}
