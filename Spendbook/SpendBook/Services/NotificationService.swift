import Foundation
import UserNotifications
import SwiftUI

@Observable
class NotificationService {
    static let shared = NotificationService()
    
    var isEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isRemindersEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isRemindersEnabled")
            if newValue {
                requestPermissions()
            } else {
                cancelAll()
            }
        }
    }

    var isWeeklyReportEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isWeeklyReportEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isWeeklyReportEnabled")
            if !newValue {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["weekly_status"])
            }
        }
    }
    
    var reminderTime: Date {
        get {
            let interval = UserDefaults.standard.double(forKey: "reminderTimeInterval")
            if interval == 0 {
                // Default to 8 PM
                return Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
            }
            return Date(timeIntervalSince1970: interval)
        }
        set {
            UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: "reminderTimeInterval")
            if isEnabled {
                scheduleDaily(at: newValue)
            }
        }
    }
    
    private init() {}
    
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            DispatchQueue.main.async {
                if success {
                    if self.isEnabled {
                        self.scheduleDaily(at: self.reminderTime)
                    }
                } else if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func scheduleDaily(at date: Date) {
        cancelAll()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to reflect"
        content.body = "Don't forget to log your expenses for today to keep your streak alive! 🔥"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// Trigger a test notification in 5 seconds
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Reminder"
        content.body = "This is what your daily Spendbook reminder will look like."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleWeeklyStatusReport(projectedSpend: Decimal, goal: Decimal) {
        guard isEnabled && isWeeklyReportEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Weekly Budget Forecast"
        let status = projectedSpend > goal ? "over pace" : "on track"
        content.body = "You are currently \(status) for this month. Tap to see your detailed spending insights."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 10
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "weekly_status", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
