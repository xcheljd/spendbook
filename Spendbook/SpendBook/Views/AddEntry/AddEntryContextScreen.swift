import SwiftUI
import SwiftData
import PhotosUI

struct AddEntryContextScreen: View {
    let amount: Decimal
    let initialDate: Date?
    let initialPhotoData: Data?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date
    @State private var selectedTags: [Tag] = []
    @State private var note: String = ""
    private var currencyService = CurrencyService.shared
    
    @StateObject private var photoService = PhotoPickerService()
    
    init(amount: Decimal, initialDate: Date? = nil, initialPhotoData: Data? = nil) {
        self.amount = amount
        self.initialDate = initialDate
        self.initialPhotoData = initialPhotoData
        _date = State(initialValue: initialDate ?? Date())
    }
    
    var canSave: Bool {
        !selectedTags.isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.Catppuccin.base.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header Amount
                Text(currencyService.format(amount))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.Catppuccin.text)
                    .padding(.top)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Date Picker
                        DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color.Catppuccin.mantle)
                            .cornerRadius(12)
                            .foregroundColor(Color.Catppuccin.text)
                        
                        // Tag Picker
                        VStack(alignment: .leading) {
                            Text("Tags")
                                .font(.headline)
                                .foregroundColor(Color.Catppuccin.subtext0)
                            
                            TagPickerView(selectedTags: $selectedTags)
                        }
                        
                        // Note Input
                        VStack(alignment: .leading) {
                            Text("Note")
                                .font(.headline)
                                .foregroundColor(Color.Catppuccin.subtext0)
                            
                            TextField("Optional note...", text: $note)
                                .padding()
                                .background(Color.Catppuccin.mantle)
                                .cornerRadius(12)
                                .foregroundColor(Color.Catppuccin.text)
                        }
                        
                        // Photo Selection
                        VStack(alignment: .leading) {
                            Text("Photo")
                                .font(.headline)
                                .foregroundColor(Color.Catppuccin.subtext0)
                            
                            if let data = photoService.processedImageData, let uiImage = UIImage(data: data) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 200)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(12)
                                        .clipped()
                                    
                                    Button(action: {
                                        photoService.processedImageData = nil
                                        photoService.selectedItem = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title)
                                            .foregroundColor(Color.Catppuccin.red)
                                            .background(Circle().fill(Color.Catppuccin.base))
                                    }
                                    .padding(8)
                                }
                            } else {
                                let blueColor = Color.Catppuccin.blue
                                PhotosPicker(selection: $photoService.selectedItem, matching: .images) {
                                    HStack {
                                        Image(systemName: "camera")
                                        Text("Add Photo")
                                    }
                                    .foregroundColor(blueColor)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(blueColor, lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                // Save Button
                Button(action: saveExpense) {
                    Text("Save Expense")
                        .font(.headline)
                        .foregroundColor(Color.Catppuccin.base)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(canSave ? Color.Catppuccin.green : Color.Catppuccin.overlay0)
                        .cornerRadius(16)
                }
                .disabled(!canSave)
                .padding()
            }
        }
        .onAppear {
            if let data = initialPhotoData {
                photoService.processedImageData = data
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func saveExpense() {
        let expense = Expense(
            amount: amount,
            date: date,
            note: note.isEmpty ? nil : note,
            photoData: photoService.processedImageData,
            tags: selectedTags
        )
        
        modelContext.insert(expense)
        
        // Smart cancellation: if we just logged for today, silence today's reminder
        if Calendar.current.isDateInToday(date) {
            NotificationService.shared.cancelAll()
        }
        
        dismiss()
    }
}
