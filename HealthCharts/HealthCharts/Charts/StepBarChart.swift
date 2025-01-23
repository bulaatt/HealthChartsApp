//
//  StepBarChart.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 04.01.2025.
//

import SwiftUI
import Charts

struct StepBarChart: View {
    
    @State private var rawSelectedDate: Date?
    
    var chartData: [WeekdayChartData]
    
    var averageSteps: Int {
        Int(chartData.map { $0.value }.average)
    }
    
    var selectedData: WeekdayChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var body: some View {
        ChartContainer(title: "Steps",
                       symbol: "figure.hiking",
                       subtitle: "Avg: \(averageSteps.formatted()) steps",
                       context: .steps,
                       isNav: true) {
            if chartData.isEmpty {
                ContentUnavailableView(
                    "No Data",
                    systemImage: "chart.bar",
                    description: Text("There is no step data from the Health App")
                )
            } else {
                Chart {
                    if let selectedData {
                        ChartAnnotationView(data: selectedData, context: .steps, showDate: true)
                    }
                    
                    RuleMark(y: .value("Average", averageSteps))
                        .foregroundStyle(Color.secondary)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                    
                    ForEach(chartData) { steps in
                        BarMark(
                            x: .value("Date", steps.date, unit: .day),
                            y: .value("Steps", steps.value)
                        )
                        .foregroundStyle(Color.stepCharts.gradient)
                        .opacity(rawSelectedDate == nil || steps.date == selectedData?.date ? 1 : 0.3)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartXAxis {
                    AxisMarks(preset: .aligned) {
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity (0.3))
                        
                        AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                    }
                }
            }
        }
    }
}

#Preview {
    StepBarChart(chartData: ChartHelper.convert(data: FakeData.steps))
}
