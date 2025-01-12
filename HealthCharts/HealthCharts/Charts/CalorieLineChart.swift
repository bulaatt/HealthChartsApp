//
//  CalorieLineChart.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 06.01.2025.
//

import SwiftUI
import Charts

struct CalorieLineChart: View {
    
    @State private var rawSelectedDate: Date?
    
    var selectedHealthMetric: HealthMetricContext
    var chartData: [HealthMetric]
    
    var avgCaloriesBurned: Double {
        guard !chartData.isEmpty else { return 0 }
        let totalCalories = chartData.reduce(0) { $0 + $1.value }
        return totalCalories / Double(chartData.count)
    }
    
    var selectedHealthMetricDate: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var body: some View {
        VStack {
            NavigationLink(value: selectedHealthMetric) {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Active Energy", systemImage: "figure.run")
                            .font(.title3.bold())
                            .foregroundStyle(.orange)
                        
                        Text("Avg: \(avgCaloriesBurned, specifier: "%.1f") kcal")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right.circle")
                        .imageScale(.large)
                }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)
            
            if chartData.isEmpty {
                ContentUnavailableView(
                    "No Data",
                    systemImage: "chart.xyaxis.line",
                    description: Text("There is no calorie data from the Health App")
                )
            } else {
                Chart {
                    if let selectedHealthMetricDate {
                        RuleMark(x: .value("Selected Metric", selectedHealthMetricDate.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(position: .top,
                                        spacing: 0,
                                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { annotationView }
                    }
                    
                    RuleMark(y: .value("Average", avgCaloriesBurned))
                        .foregroundStyle(.cyan)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                    
                    ForEach(chartData) { calorie in
                        AreaMark(
                            x: .value("Day", calorie.date, unit: .day),
                            yStart: .value("Value", calorie.value),
                            yEnd: .value("Min Value", minValue)
                        )
                        .foregroundStyle(Gradient(colors: [.orange.opacity(0.5), .clear]))
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Day", calorie.date, unit: .day),
                            y: .value("Value", calorie.value)
                        )
                        .foregroundStyle(.orange.gradient)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks(preset: .aligned) {
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity (0.3))
                        
                        AxisValueLabel()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground)))
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedHealthMetricDate?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            
            Text(selectedHealthMetricDate?.value ?? 0, format: .number.precision(.fractionLength(1)))
                .fontWeight(.heavy)
                .foregroundStyle(.orange)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.4), radius: 4)
        )
    }
}

#Preview {
    CalorieLineChart(selectedHealthMetric: .calories, chartData: FakeData.calories)
}
