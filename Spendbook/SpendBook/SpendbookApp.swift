import SwiftUI
import SwiftData

@main
struct SpendbookApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var securityManager = SecurityManager.shared
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var showAddExpense = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
            Tag.self,
            BudgetGoal.self,
        ])

        // Use documents directory for storage
        let url = URL.documentsDirectory.appendingPathComponent("Spendbook.sqlite")

        // Use local storage only for now (CloudKit requires proper entitlements)
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: url,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
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
                    AppLockView()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .active:
                    securityManager.handleAppBecomeActive()
                case .background:
                    securityManager.handleAppResignActive()
                default:
                    break
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
            // Ensure app is unlocked before showing add screen
            if hasCompletedOnboarding && securityManager.isUnlocked {
                showAddExpense = true
            }
        default:
            break
        }
    }
}
