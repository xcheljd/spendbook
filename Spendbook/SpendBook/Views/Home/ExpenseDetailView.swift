import SwiftUI
import SwiftData

struct ExpenseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    let expense: Expense

    @State private var privacyBlurState = PrivacyBlurState.shared
    @State private var localBlurEnabled: Bool = false

    private var theme: Theme { Theme(colorScheme) }

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

                        Text(expense.date.formatted(date: .long, time: .shortened))
                            .font(.body)
                            .foregroundStyle(theme.text)
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(theme.mantle)
                    .cornerRadius(16)

                    // Note Section
                    if let note = expense.note, !note.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note")
                                .font(.caption)
                                .foregroundStyle(theme.subtext0)

                            Text(note)
                                .font(.body)
                                .foregroundStyle(theme.text)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(theme.mantle)
                        .cornerRadius(16)
                    }

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
            .navigationTitle("Expense Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            // Initialize local blur state based on setting
            localBlurEnabled = !privacyBlurState.detailAutoReveal
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
    let expense = Expense(amount: 42.50, date: Date(), note: "Lunch meeting")
    return ExpenseDetailView(expense: expense)
}
