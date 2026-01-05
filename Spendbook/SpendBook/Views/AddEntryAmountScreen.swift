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
                                .foregroundColor(Color.Catppuccin.subtext0)
                            
                            Text(inputAmount)
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(Color.Catppuccin.text)
                        }
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.horizontal)
                        
                        if scannerService.isScanning {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("Analyzing receipt...")
                                    .font(.caption)
                                    .foregroundColor(Color.Catppuccin.subtext0)
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
                            .foregroundColor(Color.Catppuccin.base)
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
                        Button(action: { showingScanner = true }) {
                            Image(systemName: "camera.viewfinder")
                                .font(.title2)
                                .foregroundColor(blueColor)
                        }
                        
                        // Photo Library Picker
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                                .foregroundColor(blueColor)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView { scannedImage in
                    processScannedImage(scannedImage)
                }
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        processScannedImage(uiImage)
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
                self.scannedPhotoData = image.jpegData(compressionQuality: 0.8)
            } catch {
                print("Scan failed: \(error)")
            }
        }
    }
}

#Preview {
    AddEntryAmountScreen()
}
