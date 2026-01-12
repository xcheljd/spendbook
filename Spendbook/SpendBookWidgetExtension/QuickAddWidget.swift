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
    // Rotating friendly copy options
    private var friendlyCopy: String {
        let options = [
            "Log expense",
            "What'd you spend?",
            "Quick add",
            "Tap to track"
        ]
        // Use day of year to rotate copy daily
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return options[dayOfYear % options.count]
    }

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            // Gradient button with shadow and depth
            QuickAddButton(size: 60)

            Spacer()
                .frame(height: 4)

            // Friendly copy
            Text(friendlyCopy)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color.Catppuccin.text)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(URL(string: "spendbook://add"))
    }
}

// MARK: - Widget Configuration
struct QuickAddWidget: Widget {
    let kind: String = "QuickAddWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickAddWidgetProvider()) { entry in
            QuickAddWidgetView()
                .containerBackground(for: .widget) {
                    RadialGradient(
                        colors: [Color.Catppuccin.mantle, Color.Catppuccin.base],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                }
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
