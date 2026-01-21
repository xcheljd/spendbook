import SwiftUI
import SwiftData

struct PaymentMethodManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PaymentMethod.nickname) private var paymentMethods: [PaymentMethod]
    @State private var showingNewPaymentMethodSheet = false
    @State private var editingPaymentMethod: PaymentMethod?
    @State private var showingDeleteAlert = false
    @State private var showingArchiveAlert = false
    @State private var paymentMethodToDelete: PaymentMethod?
    @State private var paymentMethodToArchive: PaymentMethod?

    private var activePaymentMethods: [PaymentMethod] {
        paymentMethods.filter { !$0.isArchived }
    }

    private var archivedPaymentMethods: [PaymentMethod] {
        paymentMethods.filter { $0.isArchived }
    }

    var body: some View {
        List {
            // Summary Section
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(activePaymentMethods.count)")
                            .font(.title2.bold())
                            .foregroundColor(Color.Catppuccin.blue)
                        Text("Active")
                            .font(.caption)
                            .foregroundColor(Color.Catppuccin.subtext0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if let mostUsed = activePaymentMethods.max(by: { $0.expenseCount < $1.expenseCount }), mostUsed.expenseCount > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mostUsed.displayName)
                                .font(.subheadline.bold())
                                .foregroundColor(Color.Catppuccin.text)
                                .lineLimit(1)
                            Text("\(mostUsed.expenseCount) uses")
                                .font(.caption)
                                .foregroundColor(Color.Catppuccin.subtext0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 8)
            }

            // Quick Action
            Section {
                Button(action: { showingNewPaymentMethodSheet = true }) {
                    Label("Add Payment Method", systemImage: "creditcard.fill")
                        .foregroundColor(Color.Catppuccin.blue)
                }
            }

            // Active Payment Methods
            if !activePaymentMethods.isEmpty {
                Section {
                    ForEach(activePaymentMethods) { paymentMethod in
                        PaymentMethodManagementRow(
                            paymentMethod: paymentMethod,
                            isArchived: false,
                            onEdit: { editingPaymentMethod = paymentMethod },
                            onArchiveOrDelete: {
                                if paymentMethod.hasExpenses {
                                    confirmArchive(paymentMethod)
                                } else {
                                    confirmDelete(paymentMethod)
                                }
                            },
                            onRestore: nil
                        )
                    }
                } header: {
                    Text("Active (\(activePaymentMethods.count))")
                }
            } else {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 40))
                            .foregroundColor(Color.Catppuccin.overlay1)
                        Text("No Payment Methods")
                            .font(.headline)
                            .foregroundColor(Color.Catppuccin.subtext0)
                        Text("Add payment methods to track how you're spending.")
                            .font(.caption)
                            .foregroundColor(Color.Catppuccin.overlay1)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }

            // Archived Payment Methods
            if !archivedPaymentMethods.isEmpty {
                Section {
                    ForEach(archivedPaymentMethods) { paymentMethod in
                        PaymentMethodManagementRow(
                            paymentMethod: paymentMethod,
                            isArchived: true,
                            onEdit: nil,
                            onArchiveOrDelete: { confirmDelete(paymentMethod) },
                            onRestore: { restorePaymentMethod(paymentMethod) }
                        )
                    }
                } header: {
                    Text("Archived (\(archivedPaymentMethods.count))")
                } footer: {
                    Text("Archived payment methods are preserved for historical transactions but hidden from new expenses.")
                        .font(.caption)
                }
            }

            // Preset Quick Add
            if activePaymentMethods.isEmpty {
                Section {
                    Button(action: addPresets) {
                        Label("Add Common Methods", systemImage: "wand.and.stars")
                            .foregroundColor(Color.Catppuccin.green)
                    }
                } footer: {
                    Text("Quickly add Cash, Credit Card, and Debit Card.")
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Payment Methods")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNewPaymentMethodSheet) {
            PaymentMethodEditSheet(paymentMethod: nil, modelContext: modelContext)
        }
        .sheet(item: $editingPaymentMethod) { paymentMethod in
            PaymentMethodEditSheet(paymentMethod: paymentMethod, modelContext: modelContext)
        }
        .alert("Delete Payment Method?", isPresented: $showingDeleteAlert, presenting: paymentMethodToDelete) { paymentMethod in
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deletePaymentMethod(paymentMethod)
            }
        } message: { paymentMethod in
            if paymentMethod.isArchived {
                Text("Permanently delete this archived payment method? It will be removed from \(paymentMethod.expenseCount) transaction(s).")
            } else {
                Text("This payment method has no transactions. It will be permanently deleted.")
            }
        }
        .alert("Archive Payment Method?", isPresented: $showingArchiveAlert, presenting: paymentMethodToArchive) { paymentMethod in
            Button("Cancel", role: .cancel) { }
            Button("Archive") {
                archivePaymentMethod(paymentMethod)
            }
        } message: { paymentMethod in
            Text("This payment method will be hidden from new expenses but preserved in \(paymentMethod.expenseCount) existing transaction(s). You can restore it later.")
        }
    }

    private func addPresets() {
        let presets: [(nickname: String, methodType: PaymentMethodType)] = [
            ("Cash", .cash),
            ("Credit Card", .creditCard),
            ("Debit Card", .debitCard)
        ]

        for preset in presets {
            // Check if an archived version exists and restore it instead
            if let archived = archivedPaymentMethods.first(where: { $0.nickname == preset.nickname && $0.methodType == preset.methodType }) {
                archived.isArchived = false
            } else if !activePaymentMethods.contains(where: { $0.nickname == preset.nickname }) {
                let newPaymentMethod = PaymentMethod(
                    nickname: preset.nickname,
                    methodType: preset.methodType
                )
                modelContext.insert(newPaymentMethod)
            }
        }

        try? modelContext.save()
    }

    private func confirmDelete(_ paymentMethod: PaymentMethod) {
        paymentMethodToDelete = paymentMethod
        showingDeleteAlert = true
    }

    private func confirmArchive(_ paymentMethod: PaymentMethod) {
        paymentMethodToArchive = paymentMethod
        showingArchiveAlert = true
    }

    private func deletePaymentMethod(_ paymentMethod: PaymentMethod) {
        withAnimation {
            modelContext.delete(paymentMethod)
            try? modelContext.save()
        }
    }

    private func archivePaymentMethod(_ paymentMethod: PaymentMethod) {
        withAnimation {
            paymentMethod.isArchived = true
            try? modelContext.save()
        }
    }

    private func restorePaymentMethod(_ paymentMethod: PaymentMethod) {
        withAnimation {
            paymentMethod.isArchived = false
            try? modelContext.save()
        }
    }
}

// MARK: - Payment Method Management Row

struct PaymentMethodManagementRow: View {
    let paymentMethod: PaymentMethod
    let isArchived: Bool
    let onEdit: (() -> Void)?
    let onArchiveOrDelete: () -> Void
    let onRestore: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            // Icon based on type
            ZStack {
                Circle()
                    .fill(paymentMethod.methodType.color.opacity(isArchived ? 0.1 : 0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: paymentMethod.methodType.iconName)
                    .foregroundColor(paymentMethod.methodType.color.opacity(isArchived ? 0.5 : 1.0))
                    .font(.system(size: 18, weight: .medium))
            }

            // Payment method details
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(paymentMethod.displayName)
                        .font(.body)
                        .foregroundColor(isArchived ? Color.Catppuccin.subtext0 : Color.Catppuccin.text)

                    if isArchived {
                        Text("Archived")
                            .font(.caption2)
                            .foregroundColor(Color.Catppuccin.overlay1)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.Catppuccin.overlay0)
                            .cornerRadius(4)
                    }
                }

                HStack(spacing: 4) {
                    Text(paymentMethod.methodType.displayName)
                        .font(.caption)
                        .foregroundColor(Color.Catppuccin.subtext0)

                    if paymentMethod.expenseCount > 0 {
                        Text("· \(paymentMethod.expenseCount) use\(paymentMethod.expenseCount == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(Color.Catppuccin.subtext0)
                    }
                }
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if isArchived {
                // Archived: Delete permanently
                Button(role: .destructive, action: onArchiveOrDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } else if paymentMethod.hasExpenses {
                // Active with expenses: Archive
                Button(action: onArchiveOrDelete) {
                    Label("Archive", systemImage: "archivebox")
                }
                .tint(Color.Catppuccin.peach)
            } else {
                // Active without expenses: Delete
                Button(role: .destructive, action: onArchiveOrDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }

            if let onEdit = onEdit {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(Color.Catppuccin.blue)
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if let onRestore = onRestore {
                Button(action: onRestore) {
                    Label("Restore", systemImage: "arrow.uturn.backward")
                }
                .tint(Color.Catppuccin.green)
            }
        }
    }
}

// MARK: - Payment Method Edit Sheet

struct PaymentMethodEditSheet: View {
    let paymentMethod: PaymentMethod?
    let modelContext: ModelContext

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \PaymentMethod.nickname) private var existingPaymentMethods: [PaymentMethod]
    @State private var nickname: String
    @State private var selectedMethodType: PaymentMethodType
    @State private var lastDigits: String

    init(paymentMethod: PaymentMethod?, modelContext: ModelContext) {
        self.paymentMethod = paymentMethod
        self.modelContext = modelContext

        _nickname = State(initialValue: paymentMethod?.nickname ?? "")
        _selectedMethodType = State(initialValue: paymentMethod?.methodType ?? .cash)
        _lastDigits = State(initialValue: paymentMethod?.lastDigits ?? "")
    }

    private var isEditing: Bool {
        paymentMethod != nil
    }

    private var isDuplicateNickname: Bool {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return false }

        return existingPaymentMethods.contains { existing in
            // Skip the current payment method when editing
            if let current = paymentMethod, existing.persistentModelID == current.persistentModelID {
                return false
            }
            return existing.nickname.lowercased() == trimmed
        }
    }

    private var canSave: Bool {
        !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isDuplicateNickname &&
        (selectedMethodType.requiresLastDigits ? !lastDigits.isEmpty : true) &&
        (selectedMethodType.requiresLastDigits ? isValidLastDigits : true)
    }

    private var isValidLastDigits: Bool {
        let expectedCount = selectedMethodType.lastDigitsCount ?? 0
        return lastDigits.count == expectedCount && lastDigits.allSatisfy { $0.isNumber }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Nickname", text: $nickname)
                        .autocapitalization(.words)

                    if isDuplicateNickname {
                        Text("A payment method with this name already exists")
                            .font(.caption)
                            .foregroundColor(Color.Catppuccin.red)
                    }

                    Picker("Type", selection: $selectedMethodType) {
                        ForEach(PaymentMethodType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                if selectedMethodType.requiresLastDigits {
                    Section("Card Information") {
                        TextField(selectedMethodType.lastDigitsCount == 5 ? "Last 5 digits" : "Last 4 digits", text: $lastDigits)
                            .keyboardType(.numberPad)
                            .onChange(of: lastDigits) { _, newValue in
                                // Limit to max digits
                                let maxDigits = selectedMethodType.lastDigitsCount ?? 0
                                if newValue.count > maxDigits {
                                    lastDigits = String(newValue.prefix(maxDigits))
                                }
                            }

                        Text("For your reference only. No full card numbers, expirations, or CVV are stored.")
                            .font(.caption)
                            .foregroundColor(Color.Catppuccin.subtext0)
                    }
                }

                if let paymentMethod = paymentMethod, paymentMethod.hasExpenses {
                    Section("Usage") {
                        HStack {
                            Text("Expenses")
                            Spacer()
                            Text("\(paymentMethod.expenseCount)")
                                .foregroundColor(Color.Catppuccin.subtext0)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Payment Method" : "New Payment Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Create") {
                        savePaymentMethod()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private func savePaymentMethod() {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)

        if let paymentMethod = paymentMethod {
            // Edit existing
            paymentMethod.nickname = trimmedNickname
            paymentMethod.methodType = selectedMethodType
            paymentMethod.lastDigits = selectedMethodType.requiresLastDigits ? lastDigits : nil
        } else {
            // Create new
            let newPaymentMethod = PaymentMethod(
                nickname: trimmedNickname,
                lastDigits: selectedMethodType.requiresLastDigits ? lastDigits : nil,
                methodType: selectedMethodType
            )
            modelContext.insert(newPaymentMethod)
        }

        try? modelContext.save()
        dismiss()
    }
}
