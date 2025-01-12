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
    
    var selectedHealthMetric: HealthMetricContext
    var chartData: [WeekdayChartData]
    
    var selectedHealthMetricDate: WeekdayChartData? {
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
            HStack {
                VStack(alignment: .leading) {
                    Label("Averages", systemImage: "figure")
                        .font(.title3.bold())
                        .foregroundStyle(.orange)
                    
                    Text("Per Weekday (Last 28 Days)")
                        .font(.caption)
                }
                
                Spacer()
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)
            
            if chartData.isEmpty {
                ContentUnavailableView(
                    "No Data",
                    systemImage: "chart.bar.xaxis",
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
                    
                    ForEach(chartData) { calorie in
                        BarMark(
                            x: .value("Date", calorie.date, unit: .day),
                            y: .value("Steps", calorie.value)
                        )
                        .foregroundStyle(Color.orange.gradient)
                        .opacity(rawSelectedDate == nil || calorie.date == selectedHealthMetricDate?.date ? 1 : 0.3)
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
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
    CalorieBarChart(selectedHealthMetric: .calories,
                    chartData: ChartMath.averageWeekdayCount(for: FakeData.calories))
}
