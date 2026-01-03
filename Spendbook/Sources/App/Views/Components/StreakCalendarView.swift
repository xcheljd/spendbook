import SwiftUI

struct StreakCalendarView: View {
    let expenses: [Expense]
    private let calendar = Calendar.current
    
    private var daysInMonth: [Date] {
        let range = calendar.range(of: .day, in: .month, for: Date())!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Habits")
                .font(.headline)
                .foregroundColor(Color.Catppuccin.text)
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    DayCell(date: date, expenses: expenses)
                }
            }
        }
        .padding()
        .background(Color.Catppuccin.mantlet)
        .cornerRadius(20)
    }
}

struct DayCell: View {
    let date: Date
    let expenses: [Expense]
    private let calendar = Calendar.current
    
    private var dayExpenses: [Expense] {
        expenses.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private var color: Color {
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfDate = calendar.startOfDay(for: date)
        
        if startOfDate > startOfToday { return Color.Catppuccin.overlay0.opacity(0.1) }
        
        if dayExpenses.isEmpty {
            return Color.Catppuccin.green.opacity(0.6) // No Spend
        } else {
            return Color.Catppuccin.peach.opacity(0.6) // Spent
        }
    }
    
    var body: some View {
        Text("\(calendar.component(.day, from: date))")
            .font(.system(size: 10, weight: .bold))
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .background(color)
            .foregroundColor(Color.Catppuccin.base)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
