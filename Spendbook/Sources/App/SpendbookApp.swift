import SwiftUI
import SwiftData

@main
struct SpendbookApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var securityManager = SecurityManager.shared
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
            Tag.self,
            BudgetGoal.self,
        ])
        
        let groupID = "group.com.spendbook.data"
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?
            .appendingPathComponent("Spendbook.sqlite") ?? URL.documentsDirectory.appendingPathComponent("Spendbook.sqlite")

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: url,
            cloudKitDatabase: .private
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
        }
        .modelContainer(sharedModelContainer)
    }
}