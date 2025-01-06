//
//  FakeData.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 06.01.2025.
//

import Foundation

struct FakeData {
    static var steps: [HealthMetric] {
        var array: [HealthMetric] = []
        
        for i in 0..<28 {
            let healthMetric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                            value: Double.random(in: 4_000...15_000))
            array.append(healthMetric)
        }
        
        return array
    }
    
    static var calories: [HealthMetric] {
        var array: [HealthMetric] = []
        
        for i in 0..<28 {
            let healthMetric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                            value: Double.random(in: (120 + Double(i/3)...125 + Double(i/3))))
            array.append(healthMetric)
        }
        
        return array
    }
    
    static var calorieAverages: [WeekdayChartData] {
        var array: [WeekdayChartData] = []
        
        for i in 0..<7 {
            let healthMetric = WeekdayChartData(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                                value: Double.random(in: 100...200))
            array.append(healthMetric)
        }
        
        return array
    }
}
