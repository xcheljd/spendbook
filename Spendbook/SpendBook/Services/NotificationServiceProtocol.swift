import Foundation

@MainActor
protocol NotificationServiceProtocol {
    var isEnabled: Bool { get set }
    var isWeeklyReportEnabled: Bool { get set }
    var reminderTime: Date { get set }
    
    func requestPermissions()
    func scheduleDaily(at date: Date)
    func cancelAll()
    func sendTestNotification()
    func scheduleWeeklyStatusReport(projectedSpend: Decimal, goal: Decimal)
}
