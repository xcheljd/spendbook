import SwiftUI
import SwiftData

struct RecurringDueCard: View {
    let recurring: RecurringExpense
    let onLog: () -> Void
    private var currencyService = CurrencyService.shared
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Recurring Due Today")
                    .font(.caption.bold())
                    .foregroundColor(Color.Catppuccin.subtext0)
                
                Text(recurring.name)
                    .font(.headline)
                    .foregroundColor(Color.Catppuccin.text)
                
                Text(currencyService.format(recurring.amount))
                    .font(.subheadline)
                    .foregroundColor(Color.Catppuccin.blue)
            }
            
            Spacer()
            
            Button(action: onLog) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Confirm Log")
                }
                .font(.subheadline.bold())
                .foregroundColor(Color.Catppuccin.base)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.Catppuccin.blue)
                .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color.Catppuccin.mantlet)
        .cornerRadius(20)
        .shadow(color: Color.Catppuccin.blue.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
