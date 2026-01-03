import SwiftUI

struct StreakSummaryCard: View {
    let loggingStreak: Int
    let noSpendStreak: Int
    let bestLogging: Int
    let bestNoSpend: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Logging Streak
            StreakItem(
                label: "Logging",
                current: loggingStreak,
                best: bestLogging,
                color: Color.Catppuccin.peach,
                icon: "flame.fill"
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.Catppuccin.overlay0.opacity(0.3))
            
            // No Spend Streak
            StreakItem(
                label: "No Spend",
                current: noSpendStreak,
                best: bestNoSpend,
                color: Color.Catppuccin.green,
                icon: "shield.fill"
            )
        }
        .padding()
        .background(Color.Catppuccin.mantlet)
        .cornerRadius(16)
    }
}

struct StreakItem: View {
    let label: String
    let current: Int
    let best: Int
    let color: Color
    let icon: String
    
    @State private var isPulsing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .scaleEffect((current > 0 && isPulsing) ? 1.15 : 1.0)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            isPulsing = true
                        }
                    }
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.Catppuccin.subtext0)
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text("\(current)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.Catppuccin.text)
                Text("days")
                    .font(.caption2)
                    .foregroundColor(Color.Catppuccin.overlay0)
                    .padding(.bottom, 4)
            }
            
            Text("Best: \(best)")
                .font(.system(size: 10))
                .foregroundColor(Color.Catppuccin.overlay0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}