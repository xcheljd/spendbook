import SwiftUI

struct StreakCalendarView: View {
    let expenses: [Expense]
    private let calendar = Calendar.current

    @State private var displayedMonth: Date = Date()

    private var daysInMonth: [Date] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!

        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private var isCurrentMonth: Bool {
        calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
    }

    private var weekdayHeaders: [(index: Int, day: String)] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let symbols = formatter.veryShortWeekdaySymbols ?? []
        return symbols.enumerated().map { (index: $0, day: $1) }
    }

    private var leadingEmptyDays: Int {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let weekday = calendar.component(.weekday, from: startOfMonth)
        return weekday - calendar.firstWeekday
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header with navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(Color.Catppuccin.blue)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                Text(monthYearString)
                    .font(.headline)
                    .foregroundColor(Color.Catppuccin.text)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(isCurrentMonth ? Color.Catppuccin.overlay0 : Color.Catppuccin.blue)
                        .frame(width: 44, height: 44)
                }
                .disabled(isCurrentMonth)
            }

            // Weekday headers
            let columns = Array(repeating: GridItem(.flexible()), count: 7)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(weekdayHeaders, id: \.index) { item in
                    Text(item.day)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.Catppuccin.overlay0)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 8) {
                // Leading empty cells
                ForEach(0..<leadingEmptyDays, id: \.self) { _ in
                    Color.clear
                        .aspectRatio(1, contentMode: .fill)
                }

                ForEach(daysInMonth, id: \.self) { date in
                    DayCell(date: date, expenses: expenses)
                }
            }

            // Legend
            HStack(spacing: 16) {
                LegendItem(color: Color.Catppuccin.green.opacity(0.6), label: "No Spend")
                LegendItem(color: Color.Catppuccin.peach.opacity(0.6), label: "Spent")
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.Catppuccin.mantle)
        .cornerRadius(20)
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width > 0 {
                        previousMonth()
                    } else if value.translation.width < 0 && !isCurrentMonth {
                        nextMonth()
                    }
                }
        )
    }

    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
        }
    }

    private func nextMonth() {
        guard !isCurrentMonth else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(Color.Catppuccin.subtext0)
        }
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

    private var isToday: Bool {
        calendar.isDateInToday(date)
    }

    var body: some View {
        Text("\(calendar.component(.day, from: date))")
            .font(.system(size: 10, weight: .bold))
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .background(color)
            .foregroundColor(Color.Catppuccin.base)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isToday ? Color.Catppuccin.blue : Color.clear, lineWidth: 2)
            )
    }
}
