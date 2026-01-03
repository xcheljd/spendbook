import SwiftUI

struct ForecastingView: View {
    let projectedSpend: Decimal
    let goal: Decimal
    let exhaustionDate: Date?
    private var currencyService = CurrencyService.shared
    
    var paceStatus: PaceStatus {
        if goal <= 0 { return .onTrack }
        if projectedSpend > goal { return .over }
        if projectedSpend > goal * 0.9 { return .warning }
        return .onTrack
    }
    
    enum PaceStatus {
        case onTrack, warning, over
        
        var color: Color {
            switch self {
            case .onTrack: return Color.Catppuccin.green
            case .warning: return Color.Catppuccin.peach
            case .over: return Color.Catppuccin.red
            }
        }
        
        var icon: String {
            switch self {
            case .onTrack: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .over: return "exclamationmark.octagon.fill"
            }
        }
        
        var label: String {
            switch self {
            case .onTrack: return "On Track"
            case .warning: return "Running High"
            case .over: return "Over Pace"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: paceStatus.icon)
                .foregroundColor(paceStatus.color)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(paceStatus.label)
                    .font(.subheadline.bold())
                    .foregroundColor(Color.Catppuccin.text)
                
                if let date = exhaustionDate, paceStatus != .onTrack {
                    Text("Budget ends: \(date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(Color.Catppuccin.subtext0)
                } else {
                    Text("Projected: \(currencyService.format(projectedSpend))")
                        .font(.caption)
                        .foregroundColor(Color.Catppuccin.subtext0)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.Catppuccin.mantlet)
        .cornerRadius(16)
    }
}
