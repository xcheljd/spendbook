import SwiftUI
import PhotosUI
import Combine

@MainActor
class PhotoPickerService: ObservableObject {
    @Published var selectedItem: PhotosPickerItem? {
        didSet {
            Task {
                await loadAndCompressImage()
            }
        }
    }
    @Published var processedImageData: Data?
    @Published var isProcessing = false
    
    private func loadAndCompressImage() async {
        guard let item = selectedItem else { return }
        
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                // Perform compression on the image data
                if let image = UIImage(data: data) {
                    // Compress to JPEG with 0.7 quality to save space
                    processedImageData = image.jpegData(compressionQuality: 0.7)
                }
            }
        } catch {
            print("Error loading image: \(error)")
            processedImageData = nil
        }
    }
}
