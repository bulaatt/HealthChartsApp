//
//  ChartDataTypes.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 04.01.2025.
//

import Foundation

struct WeekdayChartData: Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var value: Double
}
