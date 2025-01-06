//
//  HealthMetric.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 04.01.2025.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
