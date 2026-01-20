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
    @Bindable private var privacyBlurState = PrivacyBlurState.shared
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
                        .foregroundStyle(Color.Catppuccin.subtext0)
                }

                Section("Reminders") {
                    Toggle("Daily Reminder", isOn: $notificationService.isEnabled)
                        .tint(Color.Catppuccin.blue)

                    if notificationService.isEnabled {
                        DatePicker("Time", selection: $notificationService.reminderTime, displayedComponents: .hourAndMinute)

                        Toggle("Weekly Budget Report", isOn: $notificationService.isWeeklyReportEnabled)
                            .tint(Color.Catppuccin.blue)

                        Text("Receive a weekly summary every Sunday at 10 AM showing if you're on track with your budget.")
                            .font(.caption)
                            .foregroundStyle(Color.Catppuccin.subtext0)

                        Button("Send Test Notification (5s)") {
                            notificationService.sendTestNotification()
                        }
                        .foregroundStyle(Color.Catppuccin.blue)
                    }
                }

                Section("Manage") {
                    NavigationLink(destination: RecurringExpenseManagerView()) {
                        Label("Recurring Expenses", systemImage: "repeat")
                    }

                    NavigationLink(destination: TagManagementView()) {
                        Label("Tags", systemImage: "tag.fill")
                    }
                }

                Section("Security") {
                    Toggle("Privacy Shield", isOn: $securityManager.isShieldEnabled)
                        .tint(Color.Catppuccin.blue)
                        .animation(.easeInOut(duration: 0.2), value: securityManager.isShieldEnabled)

                    if securityManager.isShieldEnabled {
                        // Lock Timeout Picker
                        Picker("Lock When Away", selection: $securityManager.lockTimeout) {
                            ForEach(LockTimeout.allCases) { timeout in
                                Text(timeout.displayName).tag(timeout)
                            }
                        }
                        .tint(Color.Catppuccin.blue)

                        // Authentication Method Picker
                        Picker("Unlock Method", selection: Binding(
                            get: { SecurityService.shared.authenticationMethod },
                            set: { newValue in
                                SecurityService.shared.authenticationMethod = newValue
                            }
                        )) {
                            ForEach(AuthenticationMethod.allCases) { method in
                                Text(method.displayName).tag(method)
                            }
                        }
                        .tint(Color.Catppuccin.blue)

                        Text(SecurityService.shared.authenticationMethod.description)
                            .font(.caption)
                            .foregroundStyle(Color.Catppuccin.subtext0)
                    }
                }

                Section("Display") {
                    Toggle("Show streak card", isOn: $privacyBlurState.showStreakCard)
                        .tint(Color.Catppuccin.blue)
                }

                Section {
                    Toggle("Enable blur on launch", isOn: $privacyBlurState.defaultEnabled)
                        .tint(Color.Catppuccin.blue)

                    Toggle("Show amounts in detail view", isOn: $privacyBlurState.detailAutoReveal)
                        .tint(Color.Catppuccin.blue)

                    Toggle("Hide amounts when leaving app", isOn: $privacyBlurState.autoEnableOnBackground)
                        .tint(Color.Catppuccin.blue)
                } header: {
                    Text("Privacy Blur")
                } footer: {
                    Text("Use the eye icon in the header to quickly show or hide amounts while using the app.")
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

            // Clear AppStorage streak data
            UserDefaults.standard.removeObject(forKey: "bestLoggingStreak")
            UserDefaults.standard.removeObject(forKey: "bestNoSpendStreak")
            UserDefaults.standard.removeObject(forKey: "lastMilestoneCelebrated")

            // Reset onboarding flag to show onboarding again
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")

            // Dismiss settings view so user sees onboarding
            dismiss()
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
            let text = try String(contentsOf: received.file, encoding: .utf8)
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
