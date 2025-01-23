//
//  CalorieChartsView.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 20.01.2025.
//

import SwiftUI

struct CalorieChartsView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    
    var body: some View {
        HealthChartsViewContainer() {
            VStack(spacing: 20) {
                CalorieLineChart(chartData: ChartHelper.convert(data: healthKitManager.calorieData))
                CalorieBarChart(chartData: ChartMath.averageWeekdayCount(for: healthKitManager.calorieData))
            }
        }
        .tint(.calorieCharts)
    }
}

#Preview {
    CalorieChartsView()
        .environment(HealthKitManager())
}
