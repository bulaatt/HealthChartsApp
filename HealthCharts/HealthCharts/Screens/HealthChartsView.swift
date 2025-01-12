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
    @State private var isShowingPermissionPrimingSheet: Bool = false
    @State private var selectedHealthMetric: HealthMetricContext = .steps
    @State private var isShowingAlert: Bool = false
    @State private var fetchError: HCError = .noData
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
                        CalorieBarChart(selectedHealthMetric: selectedHealthMetric, chartData: ChartMath.averageWeekdayCount(for: healthKitManager.calorieData))
                    }
                }
            }
            .padding()
            .scrollIndicators(.hidden)
            .task {
                await fetchHealthData()
            }
            .navigationTitle("Health Charts")
            .navigationDestination(for: HealthMetricContext.self) { healthMetric in
                HealthDataListView(healthMetric: healthMetric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet, onDismiss: {
                Task {
                    await fetchHealthData()
                }
            }, content: {
                HealthKitPermissionPrimingView()
            })
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                switch fetchError {
                case .authNotDetermined, .noData, .unableToCompleteRequest, .invalidValue:
                    EmptyView()
                case .sharingDenied(_):
                    Button("Settings") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    Button("Cancel", role: .cancel) { }
                }
            } message: { fetchError in
                Text(fetchError.failureReason)
            }
        }
        .tint(isSteps ? .mint : .orange)
    }
    
    private func fetchHealthData() async {
        do {
            try await healthKitManager.fetchStepCount()
            try await healthKitManager.fetchCalories()
        } catch HCError.authNotDetermined {
            isShowingPermissionPrimingSheet = true
        } catch HCError.noData {
            fetchError = .noData
            isShowingAlert = true
        } catch {
            fetchError = .unableToCompleteRequest
            isShowingAlert = true
        }
    }
}

#Preview {
    HealthChartsView()
        .environment(HealthKitManager())
}
