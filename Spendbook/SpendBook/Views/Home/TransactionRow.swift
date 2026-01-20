import SwiftUI

struct TransactionRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let expense: Expense
    var currencyService = CurrencyService.shared
    var isBlurred: Bool = false

    private var theme: Theme { Theme(colorScheme) }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(theme.mantle)
                    .frame(width: 48, height: 48)

                if let data = expense.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "bag")
                        .foregroundStyle(theme.blue)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.tags?.first?.fullName ?? "Uncategorized")
                    .font(.headline)
                    .foregroundStyle(theme.text)

                Text(expense.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(theme.subtext0)
            }

            Spacer()

            BlurredAmountView(amount: expense.amount, isBlurred: isBlurred)
                .font(.headline)
                .foregroundStyle(theme.text)
        }
        .padding(.vertical, 4)
    }
}
