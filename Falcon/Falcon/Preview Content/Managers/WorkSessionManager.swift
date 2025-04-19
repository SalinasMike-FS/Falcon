//
//  Clocked.swift
//  Falcon
//
//  Created by Michael Salinas on 4/14/25.
//


import UIKit
import Foundation

class WorkSessionManager {
    
    enum SessionState {
        case notClockedIn
        case working
        case onLunch
        case clockedOut
    }
    
    private(set) var clockInTime: Date?
    private(set) var clockOutTime: Date?
    private(set) var lunchStartTime: Date?
    private(set) var lunchEndTime: Date?
    
    private(set) var currentState: SessionState = .notClockedIn

    // MARK: - Clock In
    
    func clockIn() -> Bool {
        guard currentState == .notClockedIn else { return false }
        clockInTime = Date()
        currentState = .working
        return true
    }
    
    // MARK: - Start Lunch
    
    func startLunch() -> Bool {
        guard currentState == .working else { return false }
        lunchStartTime = Date()
        currentState = .onLunch
        return true
    }

    // MARK: - End Lunch
    
    func endLunch() -> Bool {
        guard currentState == .onLunch else { return false }
        lunchEndTime = Date()
        currentState = .working
        return true
    }
    
    // MARK: - Clock Out
    
    func clockOut() -> Bool {
        guard currentState == .working else { return false }
        clockOutTime = Date()
        currentState = .clockedOut
        return true
    }
    
    // MARK: - Computed Properties
    
    var totalWorkDuration: TimeInterval? {
        guard let clockIn = clockInTime, let clockOut = clockOutTime else { return nil }
        let fullDuration = clockOut.timeIntervalSince(clockIn)
        
        if let lunchStart = lunchStartTime, let lunchEnd = lunchEndTime {
            let lunchDuration = lunchEnd.timeIntervalSince(lunchStart)
            return fullDuration - lunchDuration
        } else {
            return fullDuration
        }
    }
    
    var isClockedIn: Bool {
        return currentState == .working || currentState == .onLunch
    }
}
