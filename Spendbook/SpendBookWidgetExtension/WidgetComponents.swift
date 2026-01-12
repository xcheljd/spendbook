import SwiftUI
import WidgetKit

// MARK: - Arc Progress View (for Small Widget)
/// A 170° arc progress indicator with gradient fill and glow effect
struct ArcProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat

    init(progress: Double, lineWidth: CGFloat = 6, size: CGFloat = 100) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.size = size
    }

    private var progressColor: Color {
        if progress < 0.8 {
            return Color.Catppuccin.green
        } else if progress < 1.0 {
            return Color.Catppuccin.peach
        } else {
            return Color.Catppuccin.red
        }
    }

    private var progressGradient: LinearGradient {
        if progress < 0.8 {
            return LinearGradient(
                colors: [Color.Catppuccin.green, Color.Catppuccin.sapphire],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else if progress < 1.0 {
            return LinearGradient(
                colors: [Color.Catppuccin.yellow, Color.Catppuccin.peach],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [Color.Catppuccin.peach, Color.Catppuccin.red],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    // Arc spans from -175° to +175° (170° total on each side from bottom)
    private let startAngle: Double = 95  // Start from bottom-left
    private let endAngle: Double = 85    // End at bottom-right (going clockwise)
    private let totalArc: Double = 350   // Total arc span in degrees

    var body: some View {
        ZStack {
            // Background track
            ArcShape(startAngle: startAngle, endAngle: endAngle)
                .stroke(
                    Color.Catppuccin.overlay0.opacity(0.25),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // Progress arc with glow
            ArcShape(startAngle: startAngle, endAngle: startAngle + (totalArc * progress))
                .stroke(
                    progressGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .shadow(color: progressColor.opacity(0.5), radius: 4, x: 0, y: 0)
        }
        .frame(width: size, height: size * 0.5)
    }
}

// MARK: - Arc Shape
struct ArcShape: Shape {
    let startAngle: Double
    let endAngle: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = min(rect.width, rect.height * 2) / 2 - 4

        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle - 90),
            endAngle: .degrees(endAngle - 90),
            clockwise: false
        )

        return path
    }
}

// MARK: - Ring Progress View (for Large Widget)
/// A circular ring progress indicator with gradient fill
struct RingProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat

    init(progress: Double, lineWidth: CGFloat = 8, size: CGFloat = 100) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.size = size
    }

    private var progressColor: Color {
        if progress < 0.8 {
            return Color.Catppuccin.green
        } else if progress < 1.0 {
            return Color.Catppuccin.peach
        } else {
            return Color.Catppuccin.red
        }
    }

    private var progressGradient: AngularGradient {
        if progress < 0.8 {
            return AngularGradient(
                colors: [Color.Catppuccin.sapphire, Color.Catppuccin.green, Color.Catppuccin.green],
                center: .center,
                startAngle: .degrees(-90),
                endAngle: .degrees(-90 + 360 * progress)
            )
        } else if progress < 1.0 {
            return AngularGradient(
                colors: [Color.Catppuccin.yellow, Color.Catppuccin.peach, Color.Catppuccin.peach],
                center: .center,
                startAngle: .degrees(-90),
                endAngle: .degrees(-90 + 360 * progress)
            )
        } else {
            return AngularGradient(
                colors: [Color.Catppuccin.peach, Color.Catppuccin.red, Color.Catppuccin.red],
                center: .center,
                startAngle: .degrees(-90),
                endAngle: .degrees(-90 + 360 * progress)
            )
        }
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.Catppuccin.overlay0.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: progressColor.opacity(0.4), radius: 6, x: 0, y: 0)

            // End cap dot for visual polish
            if progress > 0.02 {
                Circle()
                    .fill(progressColor)
                    .frame(width: lineWidth, height: lineWidth)
                    .offset(y: -size / 2 + lineWidth / 2)
                    .rotationEffect(.degrees(-90 + 360 * progress))
                    .shadow(color: progressColor.opacity(0.6), radius: 3, x: 0, y: 0)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Streak Badge
/// A pill-shaped badge for displaying streak achievements
struct StreakBadge: View {
    let emoji: String
    let value: String
    let label: String
    let accentColor: Color

    init(emoji: String, value: Int, label: String, accentColor: Color = Color.Catppuccin.lavender) {
        self.emoji = emoji
        self.value = "\(value)"
        self.label = label
        self.accentColor = accentColor
    }

    init(emoji: String, text: String, accentColor: Color = Color.Catppuccin.lavender) {
        self.emoji = emoji
        self.value = ""
        self.label = text
        self.accentColor = accentColor
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 10))

            if !value.isEmpty {
                Text(value)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.Catppuccin.text)
            }

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.Catppuccin.subtext0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(accentColor.opacity(0.12))
                .overlay(
                    Capsule()
                        .strokeBorder(accentColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Stat Card
/// A small card for displaying a labeled statistic
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let progress: Double?

    init(title: String, value: String, subtitle: String? = nil, progress: Double? = nil) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.progress = progress
    }

    private var progressColor: Color {
        guard let p = progress else { return Color.Catppuccin.green }
        if p < 0.8 { return Color.Catppuccin.green }
        else if p < 1.0 { return Color.Catppuccin.peach }
        else { return Color.Catppuccin.red }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(Color.Catppuccin.subtext0)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.Catppuccin.text)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            if let progress = progress {
                HorizontalProgressBar(progress: progress)
                    .frame(height: 4)
            }

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundStyle(Color.Catppuccin.subtext0)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.Catppuccin.mantle)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.Catppuccin.overlay0.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Horizontal Progress Bar
/// A pill-shaped horizontal progress bar with marker dot
struct HorizontalProgressBar: View {
    let progress: Double

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var progressColor: Color {
        if progress < 0.8 { return Color.Catppuccin.green }
        else if progress < 1.0 { return Color.Catppuccin.peach }
        else { return Color.Catppuccin.red }
    }

    private var progressGradient: LinearGradient {
        if progress < 0.8 {
            return LinearGradient(
                colors: [Color.Catppuccin.sapphire, Color.Catppuccin.green],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else if progress < 1.0 {
            return LinearGradient(
                colors: [Color.Catppuccin.yellow, Color.Catppuccin.peach],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [Color.Catppuccin.peach, Color.Catppuccin.red],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.Catppuccin.overlay0.opacity(0.25))

                // Progress fill
                Capsule()
                    .fill(progressGradient)
                    .frame(width: max(geometry.size.height, geometry.size.width * clampedProgress))
                    .shadow(color: progressColor.opacity(0.4), radius: 2, x: 0, y: 0)

                // Marker dot at end of progress
                if clampedProgress > 0.05 {
                    Circle()
                        .fill(Color.Catppuccin.text)
                        .frame(width: geometry.size.height + 2, height: geometry.size.height + 2)
                        .overlay(
                            Circle()
                                .fill(progressColor)
                                .padding(2)
                        )
                        .offset(x: max(0, geometry.size.width * clampedProgress - geometry.size.height / 2 - 1))
                }
            }
        }
    }
}

// MARK: - Encouraging Copy
/// Returns contextual encouraging copy based on budget status
struct EncouragingCopy {
    static func forBudgetProgress(_ progress: Double) -> String {
        if progress < 0.5 {
            return ["Looking good!", "On track", "Keep it up", "Nice pace"].randomElement() ?? "On track"
        } else if progress < 0.8 {
            return ["Doing well", "Steady", "Good progress", "On track"].randomElement() ?? "On track"
        } else if progress < 1.0 {
            return ["Getting close", "Easy does it", "Almost there", "Watch it"].randomElement() ?? "Getting close"
        } else {
            return ["Over, but okay", "New month soon", "It happens", "Reset coming"].randomElement() ?? "Over budget"
        }
    }

    static func forStreak(_ days: Int) -> String {
        if days == 0 { return "Start today!" }
        else if days == 1 { return "day" }
        else if days < 7 { return "days" }
        else if days == 7 { return "days!" }
        else { return "days" }
    }
}

// MARK: - Quick Add Button
/// A prominent gradient button for the Quick Add widget
struct QuickAddButton: View {
    let size: CGFloat

    init(size: CGFloat = 56) {
        self.size = size
    }

    var body: some View {
        ZStack {
            // Shadow circle (for depth)
            Circle()
                .fill(Color.black.opacity(0.2))
                .frame(width: size, height: size)
                .blur(radius: 8)
                .offset(y: 4)

            // Main button circle with gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.Catppuccin.green, Color.Catppuccin.sapphire],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    // Inner glow/highlight
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.Catppuccin.green.opacity(0.4), radius: 8, x: 0, y: 4)

            // Plus icon
            Image(systemName: "plus")
                .font(.system(size: size * 0.43, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Widget Previews
#Preview("Arc Progress") {
    VStack(spacing: 20) {
        ArcProgressView(progress: 0.3, size: 120)
        ArcProgressView(progress: 0.65, size: 120)
        ArcProgressView(progress: 0.85, size: 120)
        ArcProgressView(progress: 1.0, size: 120)
    }
    .padding()
    .background(Color.Catppuccin.base)
}

#Preview("Ring Progress") {
    HStack(spacing: 20) {
        RingProgressView(progress: 0.62, size: 80)
        RingProgressView(progress: 0.85, size: 80)
        RingProgressView(progress: 1.0, size: 80)
    }
    .padding()
    .background(Color.Catppuccin.base)
}

#Preview("Streak Badges") {
    VStack(spacing: 12) {
        StreakBadge(emoji: "🔥", value: 7, label: "days", accentColor: Color.Catppuccin.peach)
        StreakBadge(emoji: "🛡️", value: 3, label: "no-spend", accentColor: Color.Catppuccin.lavender)
        StreakBadge(emoji: "✨", text: "On track!", accentColor: Color.Catppuccin.green)
    }
    .padding()
    .background(Color.Catppuccin.base)
}

#Preview("Quick Add Button") {
    QuickAddButton(size: 64)
        .padding(40)
        .background(Color.Catppuccin.base)
}
