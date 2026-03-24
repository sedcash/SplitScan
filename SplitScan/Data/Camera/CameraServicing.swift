import AVFoundation
import UIKit

@MainActor
protocol CameraServicing {
    var isRunning: Bool { get }
    var session: AVCaptureSession { get }

    func configureIfNeeded() async throws
    func start()
    func stop()
    func capturePhoto() async throws -> UIImage
}
