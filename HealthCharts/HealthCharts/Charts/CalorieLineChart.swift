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
    
    var chartData: [WeekdayChartData]
    
    var averageCalories: Int {
        Int(chartData.map { $0.value }.average)
    }
    
    var selectedData: WeekdayChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var body: some View {
        ChartContainer(title: "Active Energy",
                       symbol: "figure.run",
                       subtitle: "Avg: \(averageCalories.formatted(.number.precision(.fractionLength(1)))) kcal",
                       context: .calories,
                       isNav: true) {
            
            if chartData.isEmpty {
                ContentUnavailableView(
                    "No Data",
                    systemImage: "chart.xyaxis.line",
                    description: Text("There is no calorie data from the Health App")
                )
            } else {
                Chart {
                    if let selectedData {
                        ChartAnnotationView(data: selectedData, context: .calories, showDate: true)
                    }
                    
                    RuleMark(y: .value("Average", averageCalories))
                        .foregroundStyle(.gray)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                    
                    ForEach(chartData) { calorie in
                        AreaMark(
                            x: .value("Day", calorie.date, unit: .day),
                            yStart: .value("Value", calorie.value),
                            yEnd: .value("Min Value", minValue)
                        )
                        .foregroundStyle(Gradient(colors: [.calorieCharts.opacity(0.5), .clear]))
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Day", calorie.date, unit: .day),
                            y: .value("Value", calorie.value)
                        )
                        .foregroundStyle(.calorieCharts.gradient)
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
    }
}

#Preview {
    CalorieLineChart(chartData: ChartHelper.convert(data: FakeData.calories))
}
