//
//  HealthChartsView.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 01.01.2025.
//

import SwiftUI
import Charts

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, calories
    var id: Self { self }
    
    var title: String {
        switch self {
        case .steps:
            return "Steps"
        case .calories:
            return "Calories"
        }
    }
}

struct HealthChartsView: View {
    
    @Environment(HealthKitManager.self) private var healthKitManager
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming: Bool = false
    @State private var isShowingPermissionPrimingSheet: Bool = false
    @State private var selectedHealthMetric: HealthMetricContext = .steps
    var isSteps: Bool { selectedHealthMetric == .steps }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Health Metric", selection: $selectedHealthMetric) {
                        ForEach(HealthMetricContext.allCases) { healthMetric in
                            Text(healthMetric.title)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    switch selectedHealthMetric {
                    case .steps:
                        StepBarChart(selectedHealthMetric: selectedHealthMetric, chartData: healthKitManager.stepData)
                        StepPieChart(chartData: ChartMath.averageWeekdayCount(for: healthKitManager.stepData))
                    case .calories:
                        CalorieLineChart(selectedHealthMetric: selectedHealthMetric, chartData: healthKitManager.calorieData)
                    }
                }
            }
            .padding()
            .scrollIndicators(.hidden)
            .task {
                await healthKitManager.fetchStepCount()
                await healthKitManager.fetchCalories()
                isShowingPermissionPrimingSheet = !hasSeenPermissionPriming
            }
            .navigationTitle("Health Charts")
            .navigationDestination(for: HealthMetricContext.self) { healthMetric in
                HealthDataListView(healthMetric: healthMetric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet) {
                // fetch health data
            } content: {
                HealthKitPermissionPrimingView(hasSeen: $hasSeenPermissionPriming)
            }
        }
        .tint(isSteps ? .mint : .orange)
    }
}

#Preview {
    HealthChartsView()
        .environment(HealthKitManager())
}
