//
//  StepChartsView.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 20.01.2025.
//

import SwiftUI

struct StepChartsView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    
    var body: some View {
        HealthChartsViewContainer() {
            VStack(spacing: 20) {
                StepBarChart(chartData: ChartHelper.convert(data: healthKitManager.stepData))
                StepPieChart(chartData: ChartMath.averageWeekdayCount(for: healthKitManager.stepData))
            }
        }
        .tint(.stepCharts)
    }
}

#Preview {
    StepChartsView()
        .environment(HealthKitManager())
}
