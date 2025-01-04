//
//  ChartMath.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 04.01.2025.
//

import Foundation
import Algorithms

struct ChartMath {
    
    static func averageWeekdayCount(for healthMetric: [HealthMetric]) -> [WeekdayChartData] {
        let sortedByWeekday = healthMetric.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        
        var weekdayChartData: [WeekdayChartData] = []
        
        for array in weekdayArray {
            guard let firstvalue = array.first else { continue }
            let average = array.reduce(0) { $0 + $1.value } / Double(array.count)
            weekdayChartData.append(.init(date: firstvalue.date, value: average))
        }
        
        return weekdayChartData
    }
}
