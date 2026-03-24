import AVFoundation
import Observation
import UIKit

@Observable
final class CameraService: NSObject, CameraServicing, @unchecked Sendable {
    enum CameraError: Error {
        case noCamera
        case cannotAddInput
        case cannotAddOutput
        case captureFailed
    }

    var isRunning = false

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let photoOutput = AVCapturePhotoOutput()
    private var configured = false

    private var captureContinuation: CheckedContinuation<UIImage, Error>?

    func configureIfNeeded() async throws {
        guard !configured else { return }

        try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async {
                do {
                    self.session.beginConfiguration()
                    self.session.sessionPreset = .photo

                    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                        throw CameraError.noCamera
                    }

                    let input = try AVCaptureDeviceInput(device: device)
                    guard self.session.canAddInput(input) else {
                        throw CameraError.cannotAddInput
                    }
                    self.session.addInput(input)

                    guard self.session.canAddOutput(self.photoOutput) else {
                        throw CameraError.cannotAddOutput
                    }
                    self.session.addOutput(self.photoOutput)

                    self.session.commitConfiguration()
                    self.configured = true
                    continuation.resume()
                } catch {
                    self.session.commitConfiguration()
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func start() {
        sessionQueue.async {
            guard self.configured, !self.session.isRunning else { return }
            self.session.startRunning()
            Task { @MainActor in
                self.isRunning = true
            }
        }
    }

    func stop() {
        sessionQueue.async {
            guard self.session.isRunning else { return }
            self.session.stopRunning()
            Task { @MainActor in
                self.isRunning = false
            }
        }
    }

    func capturePhoto() async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async {
                self.captureContinuation = continuation

                let settings = AVCapturePhotoSettings()
                settings.flashMode = .auto
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            captureContinuation?.resume(throwing: error)
            captureContinuation = nil
            return
        }

        guard
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else {
            captureContinuation?.resume(throwing: CameraError.captureFailed)
            captureContinuation = nil
            return
        }

        captureContinuation?.resume(returning: image)
        captureContinuation = nil
    }
}
