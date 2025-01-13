//
//  ChartHelper.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 12.01.2025.
//

import Foundation

struct ChartHelper {
    static func convert(data: [HealthMetric]) -> [WeekdayChartData] {
        data.map { WeekdayChartData(date: $0.date, value: $0.value) }
    }
    
    static func parseSelectedData(from data: [WeekdayChartData], in selectedDate: Date?) -> WeekdayChartData? {
        guard let selectedDate else { return nil }
        return data.first {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
    }
}
