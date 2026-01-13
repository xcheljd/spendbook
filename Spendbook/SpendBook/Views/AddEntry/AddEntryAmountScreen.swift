import SwiftUI
import PhotosUI

struct AddEntryAmountScreen: View {
    @State private var inputAmount: String = "0"
    @State private var navigateToContext: Bool = false
    private var currencyService = CurrencyService.shared

    // Scanner Integration
    @StateObject private var scannerService = ReceiptScannerService()
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingScanner = false

    // Scanned Data
    @State private var scannedDate: Date?
    @State private var scannedPhotoData: Data?

    // Error handling
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingPermissionAlert = false

    var isValid: Bool {
        guard let decimal = Decimal(string: inputAmount) else { return false }
        return decimal > 0
    }

    var decimalAmount: Decimal {
        Decimal(string: inputAmount) ?? 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.Catppuccin.base.ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    // Amount Display
                    VStack(spacing: 10) {
                        HStack(spacing: 4) {
                            Text(currencyService.selectedCurrencyCode)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.Catppuccin.subtext0)

                            Text(inputAmount)
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.Catppuccin.text)
                        }
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.horizontal)

                        if scannerService.isScanning {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("Analyzing receipt...")
                                    .font(.caption)
                                    .foregroundStyle(Color.Catppuccin.subtext0)
                            }
                            .tint(Color.Catppuccin.blue)
                        }
                    }

                    Spacer()

                    // Keypad
                    AmountKeypadView(value: $inputAmount)
                        .padding(.bottom, 20)

                    // Next Button
                    Button(action: {
                        navigateToContext = true
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundStyle(Color.Catppuccin.base)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isValid ? Color.Catppuccin.blue : Color.Catppuccin.overlay0)
                            .cornerRadius(16)
                    }
                    .disabled(!isValid)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    let blueColor = Color.Catppuccin.blue
                    HStack(spacing: 20) {
                        // Camera Scanner
                        Button(action: { requestCameraAccess() }) {
                            Image(systemName: "camera.viewfinder")
                                .font(.title2)
                                .foregroundStyle(blueColor)
                        }

                        // Photo Library Picker
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                                .foregroundStyle(blueColor)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView(
                    onCompletion: { scannedImage in
                        processScannedImage(scannedImage)
                    },
                    onError: { error in
                        showError(error.localizedDescription)
                    }
                )
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    do {
                        guard let newValue else { return }
                        guard let data = try await newValue.loadTransferable(type: Data.self) else {
                            showError("Could not load the selected photo.")
                            return
                        }
                        guard let uiImage = UIImage(data: data) else {
                            showError("Could not read the image. Please try a different photo.")
                            return
                        }
                        processScannedImage(uiImage)
                    } catch {
                        showError("Failed to load photo: \(error.localizedDescription)")
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToContext) {
                AddEntryContextScreen(
                    amount: decimalAmount,
                    initialDate: scannedDate,
                    initialPhotoData: scannedPhotoData
                )
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("Camera Unavailable", isPresented: $showingPermissionAlert) {
                if ScannerView.isDocumentScannerAvailable {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if ScannerView.isDocumentScannerAvailable {
                    Text("Please enable camera access in Settings to scan receipts.")
                } else {
                    Text("Document scanning requires a device with a camera. Use the photo picker instead.")
                }
            }
        }
    }

    private func requestCameraAccess() {
        Task {
            let status = await ScannerView.checkCameraPermission()
            switch status {
            case .authorized:
                // Small delay to let camera system initialize after permission grant
                try? await Task.sleep(for: .milliseconds(100))
                showingScanner = true
            case .denied:
                showingPermissionAlert = true
            case .notDetermined:
                break
            }
        }
    }

    private func processScannedImage(_ image: UIImage) {
        Task {
            do {
                let (amount, date) = try await scannerService.scanReceipt(image)
                if let amount = amount {
                    inputAmount = "\(amount)"
                }
                self.scannedDate = date
                if let photoData = image.jpegData(compressionQuality: 0.8) {
                    self.scannedPhotoData = photoData
                }
            } catch {
                showError(error.localizedDescription)
            }
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

#Preview {
    AddEntryAmountScreen()
}
