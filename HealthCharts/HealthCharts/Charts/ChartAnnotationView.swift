//
//  ChartAnnotationView.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 12.01.2025.
//

import SwiftUI
import Charts

struct ChartAnnotationView: ChartContent {
    
    let data: WeekdayChartData
    let context: HealthMetricContext
    let showDate: Bool
    
    private var contextColor: Color {
        switch context {
        case .steps: .stepCharts
        case .calories: .calorieCharts
        }
    }
    
    private var contextPrecision: Int {
        switch context {
        case .steps: 0
        case .calories: 1
        }
    }
    
    var body: some ChartContent {
        RuleMark(x: .value("Selected Metric", data.date, unit: .day))
            .foregroundStyle(Color.secondary.opacity(0.3))
            .offset(y: -10)
            .annotation(position: .top,
                        spacing: 0,
                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { annotationView }
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            if showDate {
                Text(data.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                    .font(.footnote.bold())
                    .foregroundStyle(.secondary)
            } else {
                Text(data.date, format: .dateTime.weekday(.wide))
                    .font(.footnote.bold())
                    .foregroundStyle(.secondary)
            }
            
            Text(data.value, format: .number.precision(.fractionLength(contextPrecision)))
                .fontWeight(.heavy)
                .foregroundStyle(contextColor)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.4), radius: 4)
        )
    }
}
