//
//  HealthChartsViewContainer.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 23.01.2025.
//

import SwiftUI

struct HealthChartsViewContainer<Content: View>: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    @State private var isShowingPermissionPrimingSheet: Bool = false
    @State private var isShowingAlert: Bool = false
    @State private var fetchError: HCError = .noData
    
    @ViewBuilder let chartContent: () -> Content
    
    var body: some View {
        NavigationStack {
            ScrollView {
                chartContent()
                    .padding(.top, 14)
            }
            .padding([.leading, .trailing])
            .scrollIndicators(.hidden)
            .task {
                await fetchHealthData()
            }
            .navigationTitle("Health Charts")
            .navigationDestination(for: HealthMetricContext.self) { healthMetric in
                HealthDataListView(healthMetric: healthMetric)
            }
            .fullScreenCover(isPresented: $isShowingPermissionPrimingSheet, onDismiss: {
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
