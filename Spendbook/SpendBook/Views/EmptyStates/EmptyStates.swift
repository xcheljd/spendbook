import SwiftUI

// MARK: - Base Empty State View
struct EmptyStateBase<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: Content
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    @State private var isFloating = false

    private var theme: Theme { Theme(colorScheme) }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            icon
                .offset(y: isFloating ? -5 : 5)
                .animation(
                    .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                    value: isFloating
                )
                .onAppear { isFloating = true }

            Text(title)
                .font(.headline)
                .foregroundColor(theme.subtext0)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(theme.overlay0)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline.bold())
                        .foregroundColor(theme.base)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(theme.blue)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }

            Spacer()
        }
    }
}

// MARK: - Transactions Empty State
struct TransactionsEmptyState: View {
    var body: some View {
        EmptyStateBase(
            icon: TransactionsEmptyIcon(),
            title: "No transactions yet",
            subtitle: "Start tracking your spending by tapping the + button below."
        )
    }
}

struct TransactionsEmptyIcon: View {
    var body: some View {
        ZStack {
            // Background wallet
            Image(systemName: "wallet.pass")
                .font(.system(size: 50))
                .foregroundColor(Color.Catppuccin.overlay0.opacity(0.5))
                .offset(x: -5, y: 5)

            // Foreground credit card with sparkle
            ZStack {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color.Catppuccin.blue.opacity(0.8))

                Image(systemName: "sparkle")
                    .font(.system(size: 16))
                    .foregroundColor(Color.Catppuccin.yellow)
                    .offset(x: 25, y: -15)
            }
            .offset(x: 10, y: -10)
        }
        .frame(height: 80)
    }
}

// MARK: - Goals Empty State
struct GoalsEmptyState: View {
    var onAddGoal: (() -> Void)? = nil

    var body: some View {
        EmptyStateBase(
            icon: GoalsEmptyIcon(),
            title: "No goals yet",
            subtitle: "Set a spending limit to stay accountable and track your progress.",
            actionTitle: "Set a Goal",
            action: onAddGoal
        )
    }
}

struct GoalsEmptyIcon: View {
    var body: some View {
        ZStack {
            // Target background
            Image(systemName: "target")
                .font(.system(size: 55))
                .foregroundColor(Color.Catppuccin.overlay0.opacity(0.4))

            // Flag on top
            Image(systemName: "flag.fill")
                .font(.system(size: 24))
                .foregroundColor(Color.Catppuccin.mauve)
                .offset(x: 20, y: -20)

            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(Color.Catppuccin.green)
                .offset(x: -22, y: 15)
        }
        .frame(height: 80)
    }
}

// MARK: - Insights Empty State
struct InsightsEmptyState: View {
    let timeframeName: String

    var body: some View {
        EmptyStateBase(
            icon: InsightsEmptyIcon(),
            title: "No spending data",
            subtitle: "There's no data for \(timeframeName.lowercased()) yet. Start logging expenses to see insights."
        )
    }
}

struct InsightsEmptyIcon: View {
    var body: some View {
        ZStack {
            // Chart bars background
            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.Catppuccin.overlay0.opacity(0.3))
                        .frame(width: 12, height: CGFloat([20, 35, 25, 40][i]))
                }
            }

            // Magnifying glass
            Image(systemName: "magnifyingglass")
                .font(.system(size: 30))
                .foregroundColor(Color.Catppuccin.sapphire)
                .offset(x: 25, y: -15)
        }
        .frame(height: 80)
    }
}

// MARK: - Filter Results Empty State
struct FilterResultsEmptyState: View {
    var onClearFilters: (() -> Void)? = nil

    var body: some View {
        EmptyStateBase(
            icon: FilterEmptyIcon(),
            title: "No matches",
            subtitle: "No expenses match your current filters. Try adjusting your criteria.",
            actionTitle: "Clear Filters",
            action: onClearFilters
        )
    }
}

struct FilterEmptyIcon: View {
    var body: some View {
        ZStack {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 50))
                .foregroundColor(Color.Catppuccin.overlay0.opacity(0.5))

            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.Catppuccin.red)
                .offset(x: 20, y: -18)
        }
        .frame(height: 80)
    }
}

// MARK: - Search Empty State
struct SearchEmptyState: View {
    let query: String

    var body: some View {
        EmptyStateBase(
            icon: SearchEmptyIcon(),
            title: "No results",
            subtitle: "Nothing found for \"\(query)\". Try a different search term."
        )
    }
}

struct SearchEmptyIcon: View {
    var body: some View {
        ZStack {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(Color.Catppuccin.overlay0.opacity(0.5))

            Image(systemName: "questionmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.Catppuccin.yellow)
                .offset(x: 22, y: -20)
        }
        .frame(height: 80)
    }
}

// MARK: - Recurring Expenses Empty State
struct RecurringEmptyState: View {
    var onAddRecurring: (() -> Void)? = nil

    var body: some View {
        EmptyStateBase(
            icon: RecurringEmptyIcon(),
            title: "No recurring expenses",
            subtitle: "Add bills and subscriptions to track them automatically.",
            actionTitle: "Add Recurring",
            action: onAddRecurring
        )
    }
}

struct RecurringEmptyIcon: View {
    var body: some View {
        ZStack {
            Image(systemName: "repeat.circle")
                .font(.system(size: 50))
                .foregroundColor(Color.Catppuccin.overlay0.opacity(0.5))

            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 22))
                .foregroundColor(Color.Catppuccin.peach)
                .offset(x: 25, y: 15)
        }
        .frame(height: 80)
    }
}
