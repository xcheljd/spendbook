import SwiftUI
import SwiftData

@main
struct SpendbookApp: App {
    @Environment(\.scenePhase) private var scenePhase
    private let securityManager = SecurityManager.shared
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var showAddExpense = false
    @State private var hasAuthenticatedSinceLastActive: Bool = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
            Tag.self,
            BudgetGoal.self,
            RecurringExpense.self,
        ])

        let url = URL.documentsDirectory.appendingPathComponent("Spendbook.sqlite")

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: url,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("❌ ModelContainer creation failed: \(error)")
            print("⚠️ Attempting to delete old database and retry...")

            let fileManager = FileManager.default
            let dbFiles = [
                url,
                url.deletingPathExtension().appendingPathExtension("sqlite-shm"),
                url.deletingPathExtension().appendingPathExtension("sqlite-wal")
            ]

            for file in dbFiles {
                try? fileManager.removeItem(at: file)
            }

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer even after cleanup: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView()
                } else if securityManager.isUnlocked {
                    HomeFeedView()
                } else {
                    AppLockView(hasAuthenticatedSinceLastActive: $hasAuthenticatedSinceLastActive)
                }
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active && oldPhase != .active && !hasAuthenticatedSinceLastActive {
                    // Check if we should lock based on timeout
                    if securityManager.shouldLock() {
                        securityManager.isUnlocked = false
                    }
                } else if newPhase == .background {
                    securityManager.handleAppResignActive()
                    hasAuthenticatedSinceLastActive = false
                }
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .sheet(isPresented: $showAddExpense) {
                AddEntryAmountScreen()
            }
        }
        .modelContainer(sharedModelContainer)
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "spendbook" else { return }

        switch url.host {
        case "add":
            if hasCompletedOnboarding && securityManager.isUnlocked {
                showAddExpense = true
            }
        default:
            break
        }
    }
}
