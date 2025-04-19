//
//  File.swift
//  Falcon
//
//  Created by Michael Salinas on 4/14/25.
//

import Foundation

struct PayManager {
    var hourlyRate: Double
    var hoursWorked: Double
    var overtimeHours: Double?
    var totalSales: Double?
    var commissionRate: Double?

    func calculatePay() -> Double {
        let basePay = hourlyRate * hoursWorked
        let overtimePay = (overtimeHours ?? 0) * hourlyRate * 1.5
        let commission = (totalSales ?? 0) * (commissionRate ?? 0)
        let totalPay = basePay + overtimePay + commission
        return totalPay
    }
}
