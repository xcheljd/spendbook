import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Quick Add Widget Entry
struct QuickAddEntry: TimelineEntry {
    let date: Date
}

// MARK: - Quick Add App Intent
struct QuickAddExpenseIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Expense"
    static let description = IntentDescription("Quickly add a new expense")
    static let openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        // This will open the app via deep link
        return .result()
    }
}

// MARK: - Timeline Provider
struct QuickAddWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickAddEntry {
        QuickAddEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (QuickAddEntry) -> Void) {
        completion(QuickAddEntry(date: Date()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickAddEntry>) -> Void) {
        let entry = QuickAddEntry(date: Date())
        // Static widget, update daily
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Quick Add Widget View
struct QuickAddWidgetView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(Color.Catppuccin.green)
            
            Text("Add Expense")
                .font(.headline)
                .foregroundColor(Color.Catppuccin.text)
            
            Text("Tap to log")
                .font(.caption)
                .foregroundColor(Color.Catppuccin.subtext0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Catppuccin.base)
        .widgetURL(URL(string: "spendbook://add"))
    }
}

// MARK: - Widget Configuration
struct QuickAddWidget: Widget {
    let kind: String = "QuickAddWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickAddWidgetProvider()) { entry in
            QuickAddWidgetView()
                .containerBackground(Color.Catppuccin.base, for: .widget)
        }
        .configurationDisplayName("Quick Add")
        .description("Quickly add a new expense")
        .supportedFamilies([.systemSmall])
    }
}



// MARK: - Preview
#Preview(as: .systemSmall) {
    QuickAddWidget()
} timeline: {
    QuickAddEntry(date: Date())
}
