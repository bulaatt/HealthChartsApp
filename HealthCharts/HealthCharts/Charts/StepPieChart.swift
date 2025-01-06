//
//  StepPieChart.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 04.01.2025.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    
    @State private var rawSelectedChartValue: Double? = 4_000
    @State private var lastRawSelectedChartValue: Double? = 4_000
    
    var selectedWeekday: WeekdayChartData? {
        guard let lastRawSelectedChartValue else { return nil }
        var total = 0.0
        
        return chartData.first {
            total += $0.value
            return lastRawSelectedChartValue <= total
        }
    }
    
    var chartData: [WeekdayChartData]
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Label("Averages", systemImage: "calendar")
                    .font(.title3.bold())
                    .foregroundStyle(.mint)
                Text("Last 28 Days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 12)
            
            Chart {
                ForEach(chartData) { weekday in
                    var isWeekdaySelected: Bool { selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt }
                    
                    SectorMark(angle: .value("Average Steps", weekday.value),
                               innerRadius: .ratio(0.618),
                               outerRadius: isWeekdaySelected ? 140 : 110,
                               angularInset: 1.6)
                    .foregroundStyle(.mint.gradient)
                    .cornerRadius(8)
                    .opacity(isWeekdaySelected ? 1.0 : 0.3)
                }
            }
            .frame(height: 240)
            .chartAngleSelection(value: $rawSelectedChartValue.animation(.easeInOut))
            .onChange(of: rawSelectedChartValue) {
                if let rawSelectedChartValue {
                    withAnimation(.easeInOut) {
                        lastRawSelectedChartValue = rawSelectedChartValue
                    }
                }
            }
            .chartBackground { proxy in
                GeometryReader { geometry in
                    if let plotFrame = proxy.plotFrame {
                        let frame = geometry[plotFrame]
                        if let selectedWeekday {
                            VStack {
                                Text(selectedWeekday.date.weekdayTitle)
                                    .font(.title3.bold())
                                    .contentTransition(.identity)
                                
                                Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                            }
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    StepPieChart(chartData: ChartMath.averageWeekdayCount(for: HealthMetric.fakeData))
}
