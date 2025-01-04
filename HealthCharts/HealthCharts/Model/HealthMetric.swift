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
    
    static var fakeData: [HealthMetric] {
        var array: [HealthMetric] = []
        
        for i in 0..<28 {
            let healthMetric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                            value: Double.random(in: 4_000...15_000))
            array.append(healthMetric)
        }
        
        return array
    }
}
