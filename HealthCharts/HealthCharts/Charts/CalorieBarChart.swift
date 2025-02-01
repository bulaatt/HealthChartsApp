//
//  CalorieBarChart.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 06.01.2025.
//

import SwiftUI
import Charts

struct CalorieBarChart: View {
    
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var chartData: [WeekdayChartData]
    
    var selectedData: WeekdayChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var body: some View {
        ChartContainer(title: "Averages",
                       symbol: "figure",
                       subtitle: "Per Weekday (Last 28 Days)",
                       context: .calories,
                       isNav: false) {
            if chartData.isEmpty {
                ContentUnavailableView(
                    "No Data",
                    systemImage: "chart.bar.xaxis",
                    description: Text("There is no calorie data from the Health App")
                )
            } else {
                Chart {
                    if let selectedData {
                        ChartAnnotationView(data: selectedData, context: .calories, showDate: false)
                    }
                    
                    ForEach(chartData) { calorie in
                        BarMark(
                            x: .value("Date", calorie.date, unit: .day),
                            y: .value("Steps", calorie.value)
                        )
                        .foregroundStyle(Color.calorieCharts.gradient)
                        .opacity(rawSelectedDate == nil || calorie.date == selectedData?.date ? 1 : 0.3)
                    }
                }
                .frame(height: 220)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.weekday(), centered: true)
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
                       .sensoryFeedback(.selection, trigger: selectedDay)
                       .onChange(of: rawSelectedDate) { oldValue, newValue in
                           if oldValue?.weekdayInt != newValue?.weekdayInt {
                               selectedDay = newValue
                           }
                       }
    }
}

#Preview {
    CalorieBarChart(chartData: ChartMath.averageWeekdayCount(for: FakeData.calories))
}
