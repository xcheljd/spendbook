import SwiftUI
import Charts

struct SpendingTrendsChart: View {
    let data: [DaySpending]
    @State private var selectedDate: Date?
    var currencyService = CurrencyService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Spending")
                .font(.headline)
                .foregroundColor(Color.Catppuccin.text)
            
            Chart {
                ForEach(data) { day in
                    BarMark(
                        x: .value("Date", day.date, unit: .day),
                        y: .value("Amount", Double(truncating: day.totalAmount as NSNumber))
                    )
                    .foregroundStyle(Color.Catppuccin.blue.gradient)
                    .cornerRadius(4)
                }
                
                if let selectedDate {
                    RuleMark(x: .value("Selected", selectedDate, unit: .day))
                        .foregroundStyle(Color.Catppuccin.overlay1)
                        .annotation(position: .top, spacing: 0) {
                            if let day = data.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                                Text(currencyService.format(day.totalAmount))
                                    .font(.caption.bold())
                                    .foregroundColor(Color.Catppuccin.base)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.Catppuccin.text)
                                    .cornerRadius(8)
                            }
                        }
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.Catppuccin.overlay0.opacity(0.3))
                    AxisValueLabel(format: .dateTime.day().month())
                        .foregroundStyle(Color.Catppuccin.subtext0)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.Catppuccin.overlay0.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(Color.Catppuccin.subtext0)
                }
            }
            .chartXSelection(value: $selectedDate)
        }
        .padding()
        .background(Color.Catppuccin.mantle)
        .cornerRadius(20)
    }
}

struct CategoryBreakdownChart: View {
    let data: [CategorySpending]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Breakdown")
                .font(.headline)
                .foregroundColor(Color.Catppuccin.text)
            
            if data.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "chart.pie")
                            .font(.largeTitle)
                        Text("No data available")
                            .font(.subheadline)
                    }
                    .foregroundColor(Color.Catppuccin.overlay0)
                    .padding(.vertical, 40)
                    Spacer()
                }
            } else {
                Chart {
                    ForEach(data) { category in
                        SectorMark(
                            angle: .value("Amount", Double(truncating: category.totalAmount as NSNumber)),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(Color(hex: category.colorHex))
                        .cornerRadius(5)
                    }
                }
                .frame(height: 200)
                .chartLegend(position: .bottom, alignment: .leading, spacing: 10)
            }
        }
        .padding()
        .background(Color.Catppuccin.mantle)
        .cornerRadius(20)
    }
}
