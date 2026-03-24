import Foundation
import UIKit

struct ReceiptImageStore {
    func load(path: String) -> UIImage? {
        UIImage(contentsOfFile: path)
    }

    func save(
        _ image: UIImage,
        fileName: String = UUID().uuidString + ".jpg"
    ) throws -> String {
        let url = try makeURL(fileName: fileName)

        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw CocoaError(.fileWriteUnknown)
        }

        try data.write(to: url, options: .atomic)
        return url.path
    }

    private func makeURL(fileName: String) throws -> URL {
        try receiptImagesDirectoryURL().appendingPathComponent(fileName)
    }

    private func receiptImagesDirectoryURL() throws -> URL {
        let baseURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("ReceiptImages", isDirectory: true)

        try FileManager.default.createDirectory(
            at: baseURL,
            withIntermediateDirectories: true
        )

        return baseURL
    }
}
