import SwiftUI
import VisionKit
import AVFoundation

enum CameraPermissionStatus {
    case authorized
    case denied
    case notDetermined
}

struct ScannerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) @MainActor private var dismiss
    let onCompletion: (UIImage) -> Void
    let onError: (Error) -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    static var isDocumentScannerAvailable: Bool {
        VNDocumentCameraViewController.isSupported
    }

    static func checkCameraPermission() async -> CameraPermissionStatus {
        guard isDocumentScannerAvailable else {
            return .denied
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            return granted ? .authorized : .denied
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }

    @MainActor
    class Coordinator: NSObject, @preconcurrency VNDocumentCameraViewControllerDelegate {
        let parent: ScannerView

        init(parent: ScannerView) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                parent.onError(ScannerError.noPages)
                parent.dismiss()
                return
            }

            let image = scan.imageOfPage(at: 0)
            parent.onCompletion(image)
            parent.dismiss()
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.onError(ScannerError.cameraUnavailable(error))
            parent.dismiss()
        }
    }
}

enum ScannerError: LocalizedError {
    case noPages
    case cameraAccessDenied
    case cameraUnavailable(Error)

    var errorDescription: String? {
        switch self {
        case .noPages:
            return "No pages were scanned. Please try again."
        case .cameraAccessDenied:
            return "Camera access is required to scan receipts. Please enable it in Settings."
        case .cameraUnavailable:
            return "Unable to access the camera. Please close other apps using the camera and try again."
        }
    }
}
