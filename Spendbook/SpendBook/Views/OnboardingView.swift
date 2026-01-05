import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    @State private var currentPage = 0
    @State private var budgetAmount: String = "500"
    
    var body: some View {
        ZStack {
            Color.Catppuccin.base.ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Slide 1
                OnboardingSlide(
                    title: "Radical Accountability",
                    description: "Manual entry is a feature, not a missing sync. Every log is a moment of reflection.",
                    icon: "hand.tap.fill",
                    color: Color.Catppuccin.blue
                )
                .tag(0)
                
                // Slide 2
                OnboardingSlide(
                    title: "Private by Design",
                    description: "Your financial data stays on your device or in your private iCloud. We never see it.",
                    icon: "lock.shield.fill",
                    color: Color.Catppuccin.green
                )
                .tag(1)
                
                // Slide 3
                OnboardingSlide(
                    title: "Build the Habit",
                    description: "Streaks and daily reminders keep you accountable until tracking becomes second nature.",
                    icon: "flame.fill",
                    color: Color.Catppuccin.peach
                )
                .tag(2)
                
                // Slide 4: Setup
                BudgetSetupSlide(amount: $budgetAmount, onFinish: finishOnboarding)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            // Skip/Next button (Top trailing)
            VStack {
                HStack {
                    Spacer()
                    if currentPage < 3 {
                        Button("Skip") {
                            withAnimation { currentPage = 3 }
                        }
                        .foregroundColor(Color.Catppuccin.subtext0)
                        .padding()
                    }
                }
                Spacer()
            }
        }
    }
    
    private func finishOnboarding() {
        // Persist Budget Goal
        let amountValue = Decimal(string: budgetAmount) ?? 500
        let goal = BudgetGoal(type: .total, period: .monthly, limitAmount: amountValue)
        modelContext.insert(goal)
        
        // Seed default tags
        let tagSeeder = TagSeeder(modelContext: modelContext)
        tagSeeder.seedDefaultTags()
        
        // Request Permissions
        NotificationService.shared.requestPermissions()
        
        // Finalize state
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingSlide: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: icon)
                .font(.system(size: 100))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.3), radius: 20)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color.Catppuccin.text)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(Color.Catppuccin.subtext0)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.bottom, 100)
    }
}

struct BudgetSetupSlide: View {
    @Binding var amount: String
    let onFinish: () -> Void
    var currencyService = CurrencyService.shared
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Set Your Target")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color.Catppuccin.text)
            
            Text("What's your target monthly spending limit? You can change this anytime.")
                .font(.body)
                .foregroundColor(Color.Catppuccin.subtext0)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            HStack {
                Text(currencyService.selectedCurrencyCode)
                    .font(.title2.bold())
                    .foregroundColor(Color.Catppuccin.subtext0)
                
                TextField("0", text: $amount)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .frame(width: 150)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.Catppuccin.mantle)
            .cornerRadius(20)
            
            Button(action: onFinish) {
                Text("Start Tracking")
                    .font(.headline)
                    .foregroundColor(Color.Catppuccin.base)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.Catppuccin.blue)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .padding(.bottom, 100)
    }
}
