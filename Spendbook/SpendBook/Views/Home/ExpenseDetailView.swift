import SwiftUI
import SwiftData

struct ExpenseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    let expense: Expense

    @State private var localBlurEnabled: Bool = false
    @State private var isEditMode: Bool = false
    @State private var editedVendor: String = ""
    @State private var editedPaymentMethod: PaymentMethod?
    @State private var editedDate: Date = Date()
    @State private var editedNote: String = ""
    @State private var editedTags: [Tag] = []

    @Query(sort: \PaymentMethod.nickname) private var paymentMethods: [PaymentMethod]

    /// Payment methods available for selection in edit mode (active + current if archived)
    private var selectablePaymentMethods: [PaymentMethod] {
        var methods = paymentMethods.filter { !$0.isArchived }
        // Include current method if it's archived (so user can keep it selected)
        if let current = editedPaymentMethod, current.isArchived, !methods.contains(where: { $0.persistentModelID == current.persistentModelID }) {
            methods.append(current)
        }
        return methods.sorted { $0.nickname < $1.nickname }
    }

    private var privacyBlurState: PrivacyBlurState { PrivacyBlurState.shared }

    private     var theme: Theme { Theme(colorScheme) }

    init(expense: Expense) {
        self.expense = expense
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Amount Section
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            BlurredAmountView(amount: expense.amount, isBlurred: localBlurEnabled)
                                .font(.system(size: 48, weight: .bold, design: .rounded))

                            Button(action: {
                                localBlurEnabled.toggle()
                            }) {
                                Image(systemName: localBlurEnabled ? "eye.slash" : "eye")
                                    .font(.title3)
                                    .foregroundStyle(theme.blue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 20)

                    // Date Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date & Time")
                            .font(.caption)
                            .foregroundStyle(theme.subtext0)

                        if isEditMode {
                            DatePicker("", selection: $editedDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        } else {
                            Text(expense.date.formatted(date: .long, time: .shortened))
                                .font(.body)
                                .foregroundStyle(theme.text)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(theme.mantle)
                    .cornerRadius(16)

                    // Vendor Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Vendor")
                            .font(.caption)
                            .foregroundStyle(theme.subtext0)

                        if isEditMode {
                            TextField("Where did you spend?", text: $editedVendor)
                                .textFieldStyle(.plain)
                                .font(.body)
                                .foregroundStyle(theme.text)
                        } else {
                            Text(expense.vendor)
                                .font(.body)
                                .foregroundStyle(theme.text)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(theme.mantle)
                    .cornerRadius(16)

                    // Payment Method Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payment Method")
                            .font(.caption)
                            .foregroundStyle(theme.subtext0)

                        if isEditMode {
                            Menu {
                                ForEach(selectablePaymentMethods) { method in
                                    Button {
                                        editedPaymentMethod = method
                                    } label: {
                                        HStack {
                                            Image(systemName: method.methodType.iconName)
                                            Text(method.displayName)
                                            if method.isArchived {
                                                Text("(Archived)")
                                            }
                                            if editedPaymentMethod?.persistentModelID == method.persistentModelID {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    if let selected = editedPaymentMethod {
                                        Image(systemName: selected.methodType.iconName)
                                        Text(selected.displayName)
                                        if selected.isArchived {
                                            Text("(Archived)")
                                                .font(.caption)
                                                .foregroundStyle(theme.overlay1)
                                        }
                                    } else {
                                        Text("Select Payment Method")
                                            .foregroundStyle(theme.subtext0)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundStyle(theme.subtext0)
                                }
                            }
                        } else if let paymentMethod = expense.paymentMethod {
                            HStack(spacing: 8) {
                                Image(systemName: paymentMethod.methodType.iconName)
                                Text(paymentMethod.displayName)
                                if paymentMethod.isArchived {
                                    Text("(Archived)")
                                        .font(.caption)
                                        .foregroundStyle(theme.overlay1)
                                }
                            }
                            .font(.body)
                            .foregroundStyle(theme.text)
                        } else {
                            Text("No payment method")
                                .font(.body)
                                .foregroundStyle(theme.subtext0)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(theme.mantle)
                    .cornerRadius(16)

                    // Tags Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.caption)
                            .foregroundStyle(theme.subtext0)

                        if isEditMode {
                            Text("Tags are optional - tap to manage in Settings")
                                .font(.caption)
                                .foregroundStyle(theme.subtext0)
                        }

                        if isEditMode {
                            if !editedTags.isEmpty {
                                FlowLayout(spacing: 8) {
                                    ForEach(editedTags) { tag in
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(Color(hex: tag.colorHex))
                                                .frame(width: 8, height: 8)
                                            Text(tag.fullName)
                                                .font(.subheadline)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(theme.overlay0.opacity(0.3))
                                        .cornerRadius(8)
                                    }
                                }
                            } else {
                                Text("No tags")
                                    .font(.body)
                                    .foregroundStyle(theme.subtext0)
                            }
                        } else {
                            if let tags = expense.tags, !tags.isEmpty {
                                FlowLayout(spacing: 8) {
                                    ForEach(tags) { tag in
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(Color(hex: tag.colorHex))
                                                .frame(width: 8, height: 8)
                                            Text(tag.fullName)
                                                .font(.subheadline)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(theme.overlay0.opacity(0.3))
                                        .cornerRadius(8)
                                    }
                                }
                            } else {
                                Text("No tags")
                                    .font(.body)
                                    .foregroundStyle(theme.subtext0)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(theme.mantle)
                    .cornerRadius(16)

                    // Note Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note")
                            .font(.caption)
                            .foregroundStyle(theme.subtext0)

                        if isEditMode {
                            TextField("Optional note...", text: $editedNote)
                                .textFieldStyle(.plain)
                                .font(.body)
                                .foregroundStyle(theme.text)
                        } else if let note = expense.note, !note.isEmpty {
                            Text(note)
                                .font(.body)
                                .foregroundStyle(theme.text)
                        } else if !isEditMode {
                            Text("No note")
                                .font(.body)
                                .foregroundStyle(theme.subtext0)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(theme.mantle)
                    .cornerRadius(16)

                    // Photo Section
                    if let photoData = expense.photoData, let uiImage = UIImage(data: photoData) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Receipt")
                                .font(.caption)
                                .foregroundStyle(theme.subtext0)

                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(16)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .background(theme.base)
            .navigationTitle(isEditMode ? "Edit Expense" : "Expense Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if isEditMode {
                        Button("Cancel") {
                            isEditMode = false
                            resetEditedValues()
                        }
                    } else {
                        Button("Done") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isEditMode {
                        Button("Save") {
                            saveChanges()
                        }
                    } else {
                        Button("Edit") {
                            isEditMode = true
                            initializeEditedValues()
                        }
                    }
                }
            }
        }
        .onAppear {
            localBlurEnabled = privacyBlurState.isEnabled && !privacyBlurState.detailAutoReveal
            initializeEditedValues()
        }
    }

    private func initializeEditedValues() {
        editedVendor = expense.vendor
        editedPaymentMethod = expense.paymentMethod
        editedDate = expense.date
        editedNote = expense.note ?? ""
        editedTags = expense.tags ?? []
    }

    private func resetEditedValues() {
        initializeEditedValues()
    }

    private func saveChanges() {
        withAnimation {
            expense.vendor = editedVendor.trimmingCharacters(in: .whitespacesAndNewlines)
            expense.paymentMethod = editedPaymentMethod
            expense.date = editedDate
            expense.note = editedNote.isEmpty ? nil : editedNote
            expense.tags = editedTags
            isEditMode = false

            try? modelContext.save()
        }
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

#Preview {
    let expense = Expense(amount: 42.50, date: Date(), vendor: "Cafe Milano", note: "Lunch meeting")
    return ExpenseDetailView(expense: expense)
}
