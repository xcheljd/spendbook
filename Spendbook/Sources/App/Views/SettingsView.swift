import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var expenses: [Expense]
    @Query private var tags: [Tag]
    @Query private var goals: [BudgetGoal]
    
    @State private var securityManager = SecurityManager.shared
    @Bindable private var currencyService = CurrencyService.shared
    @Bindable private var notificationService = NotificationService.shared
    @State private var showDeleteConfirmation = false
    
    private let exportService = DataExportService()
    
    var csvFile: CSVDocument {
        CSVDocument(initialText: exportService.generateCSV(from: expenses))
    }
    
    var jsonFile: JSONDocument? {
        if let data = try? exportService.generateJSON(from: expenses) {
            return JSONDocument(initialData: data)
        }
        return nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Region & Currency") {
                    Picker("Primary Currency", selection: $currencyService.selectedCurrencyCode) {
                        ForEach(currencyService.commonCurrencies, id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                    
                    Text("All amounts will be formatted using \(currencyService.selectedCurrencyCode) and your current regional settings.")
                        .font(.caption)
                        .foregroundColor(Color.Catppuccin.subtext0)
                }
                
                Section("Reminders") {
                    Toggle("Daily Reminder", isOn: $notificationService.isEnabled)
                        .tint(Color.Catppuccin.blue)
                    
                    if notificationService.isEnabled {
                        DatePicker("Time", selection: $notificationService.reminderTime, displayedComponents: .hourAndMinute)
                        
                        Button("Send Test Notification (5s)") {
                            notificationService.sendTestNotification()
                        }
                        .foregroundColor(Color.Catppuccin.blue)
                    }
                }
                
                Section("Manage") {
                    NavigationLink(destination: RecurringExpenseManagerView()) {
                        Label("Recurring Expenses", systemImage: "repeat")
                    }
                }
                
                Section("Security") {
                    Toggle("Privacy Shield", isOn: $securityManager.isShieldEnabled)
                        .tint(Color.Catppuccin.blue)
                    
                    if securityManager.isShieldEnabled {
                        Text("Secure your data with FaceID or Passcode. Locks after 30 seconds in background.")
                            .font(.caption)
                            .foregroundColor(Color.Catppuccin.subtext0)
                    }
                }
                
                Section("Data Sovereignty") {
                    ShareLink(item: csvFile, preview: SharePreview("Spendbook Expenses.csv")) {
                        Label("Export as CSV", systemImage: "tablecells")
                    }
                    
                    if let json = jsonFile {
                        ShareLink(item: json, preview: SharePreview("Spendbook Data.json")) {
                            Label("Export as JSON", systemImage: "curlybraces")
                        }
                    }
                }
                
                Section("Danger Zone") {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Erase All Content", systemImage: "trash")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("iCloud Sync")
                        Spacer()
                        Text("Private Database")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Erase All Data?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Erase", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This action cannot be undone. All expenses, tags, and goals will be permanently deleted.")
            }
        }
    }
    
    private func deleteAllData() {
        do {
            // Delete all expenses
            for expense in expenses {
                modelContext.delete(expense)
            }
            // Delete all tags
            for tag in tags {
                modelContext.delete(tag)
            }
            // Delete all goals
            for goal in goals {
                modelContext.delete(goal)
            }
            
            try modelContext.save()
        } catch {
            print("Failed to delete data: \(error)")
        }
    }
}

// MARK: - Transferable Documents

struct CSVDocument: Transferable {
    var initialText: String
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .commaSeparatedText) { document in
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Spendbook_Export.csv")
            try document.initialText.write(to: tempURL, atomically: true, encoding: .utf8)
            return SentTransferredFile(tempURL)
        } importing: { received in
            let text = try String(contentsOf: received.file)
            return CSVDocument(initialText: text)
        }
    }
}

struct JSONDocument: Transferable {
    var initialData: Data
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .json) { document in
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Spendbook_Export.json")
            try document.initialData.write(to: tempURL)
            return SentTransferredFile(tempURL)
        } importing: { received in
            let data = try Data(contentsOf: received.file)
            return JSONDocument(initialData: data)
        }
    }
}