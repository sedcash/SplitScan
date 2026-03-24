import AVFoundation

protocol CameraAuthorizing {
    func requestAccess() async -> Bool
}

struct CameraAuthorizationService: CameraAuthorizing {
    func requestAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }
}
