import WidgetKit
import SwiftUI
import Charts

struct SpendbookWidgets: WidgetBundle {
    var body: some Widget {
        QuickLogWidget()
        StatusOverviewWidget()
    }
}

// MARK: - Small Widget (Quick Log)
struct QuickLogWidget: Widget {
    let kind: String = "QuickLogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QuickLogWidgetView(entry: entry)
        }
        .configurationDisplayName("Quick Log")
        .description("Deep-link directly to adding an expense.")
        .supportedFamilies([.systemSmall])
    }
}

struct QuickLogWidgetView: View {
    var entry: WidgetEntry

    var body: some View {
        VStack {
            Link(destination: URL(string: "spendbook://add")!) {
                ZStack {
                    Circle()
                        .fill(Color.Catppuccin.blue)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "plus")
                        .font(.title.bold())
                        .foregroundColor(Color.Catppuccin.base)
                }
            }
            Text("Log Expense")
                .font(.caption.bold())
                .foregroundColor(Color.Catppuccin.text)
        }
        .containerBackground(Color.Catppuccin.base, for: .widget)
    }
}

// MARK: - Medium Widget (Status Dashboard)
struct StatusOverviewWidget: Widget {
    let kind: String = "StatusOverviewWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StatusOverviewWidgetView(entry: entry)
        }
        .configurationDisplayName("Status Dashboard")
        .description("View your daily budget and streaks at a glance.")
        .supportedFamilies([.systemMedium])
    }
}

struct StatusOverviewWidgetView: View {
    var entry: WidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Safe to Spend")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.Catppuccin.subtext0)
                
                Text(entry.safeToSpend.formatted(.currency(code: "USD")))
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.Catppuccin.blue)
                
                Button(intent: LogOneDollarIntent()) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Log $1.00")
                    }
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.Catppuccin.sapphire)
                    .foregroundColor(Color.Catppuccin.base)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                HStack(spacing: 12) {
                    WidgetStreakIconView(value: entry.loggingStreak, icon: "flame.fill", color: Color.Catppuccin.peach)
                    WidgetStreakIconView(value: entry.noSpendStreak, icon: "shield.fill", color: Color.Catppuccin.green)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Mini Chart
            VStack(alignment: .trailing) {
                Chart {
                    ForEach(entry.last7DaysSpending) { day in
                        BarMark(
                            x: .value("Day", day.date, unit: .day),
                            y: .value("Amount", Double(truncating: day.totalAmount as NSNumber))
                        )
                        .foregroundStyle(Color.Catppuccin.blue.opacity(0.5))
                        .cornerRadius(2)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(width: 80, height: 60)
                
                Text("Last 7 Days")
                    .font(.system(size: 8))
                    .foregroundColor(Color.Catppuccin.overlay0)
            }
        }
        .padding()
        .containerBackground(Color.Catppuccin.mantlet, for: .widget)
    }
}

struct WidgetStreakIconView: View {
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            Text("\(value)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.Catppuccin.text)
        }
    }
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), safeToSpend: 50, loggingStreak: 5, noSpendStreak: 2, last7DaysSpending: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        Task {
            let entry = await WidgetDataProvider.shared.fetchLatestData()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> ()) {
        Task {
            let entry = await WidgetDataProvider.shared.fetchLatestData()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}
