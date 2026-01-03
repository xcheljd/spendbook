import Foundation
import SwiftUI

@Observable
class SecurityManager {
    static let shared = SecurityManager()
    
    var isUnlocked: Bool = false
    
    // Using UserDefaults for the setting
    var isShieldEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isShieldEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isShieldEnabled")
            if !newValue {
                isUnlocked = true
            }
        }
    }
    
    private var lastBackgroundTime: Date?
    private let gracePeriod: TimeInterval = 30 // 30 seconds
    
    init() {
        // App starts locked if shield is enabled
        isUnlocked = !UserDefaults.standard.bool(forKey: "isShieldEnabled")
    }
    
    func lock() {
        guard isShieldEnabled else { return }
        isUnlocked = false
    }
    
    func unlock() {
        isUnlocked = true
    }
    
    func handleAppResignActive() {
        lastBackgroundTime = Date()
    }
    
    func handleAppBecomeActive() {
        guard isShieldEnabled else { 
            isUnlocked = true
            return 
        }
        
        if let lastBackgroundTime = lastBackgroundTime {
            let elapsed = Date().timeIntervalSince(lastBackgroundTime)
            if elapsed > gracePeriod {
                isUnlocked = false
            }
        } else {
            // Cold start
            isUnlocked = false
        }
    }
}
