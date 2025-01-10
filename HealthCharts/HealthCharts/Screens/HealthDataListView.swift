//
//  HealthDataListView.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 02.01.2025.
//

import SwiftUI
import HealthKit

struct HealthDataListView: View {
    
    @Environment(HealthKitManager.self) private var healthKitManager
    @State private var isShowingAddDataSheet: Bool = false
    @State private var isShowingAlert: Bool = false
    @State private var writeError: HCError = .noData
    @State private var addDataDate: Date = .now
    @State private var valueToAdd: String = ""
    
    var healthMetric: HealthMetricContext
    
    var listData: [HealthMetric] {
        healthMetric == .steps ? healthKitManager.stepData : healthKitManager.calorieData
    }
    
    var body: some View {
        List(listData.reversed()) { data in
            HStack {
                Text(data.date, format: .dateTime.month(.abbreviated).day(.twoDigits).year())
                Spacer()
                Text(data.value, format: .number.precision(.fractionLength(healthMetric == .steps ? 0 : 1)))
            }
        }
        .navigationTitle(healthMetric.title)
        .sheet(isPresented: $isShowingAddDataSheet) {
            addDataSheet
        }
        .toolbar {
            Button("Add Data", systemImage: "plus") {
                isShowingAddDataSheet = true
            }
        }
    }
    
    var addDataSheet: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
                HStack {
                    Text(healthMetric.title)
                    Spacer()
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                        .keyboardType(healthMetric == .steps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(healthMetric.title)
            .toolbarTitleDisplayMode(.inline)
            .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
                switch writeError {
                case .authNotDetermined, .noData, .unableToCompleteRequest:
                    EmptyView()
                case .sharingDenied(_):
                    Button("Settings") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    Button("Cancel", role: .cancel) { }
                }
            } message: { writeError in
                Text(writeError.failureReason)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        Task {
                            do {
                                try await addHealthData(for: addDataDate, value: Double(valueToAdd)!)
                                isShowingAlert = false
                                isShowingAddDataSheet = false
                            } catch let error as HCError {
                                handleError(error)
                            } catch {
                                handleError(nil)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        isShowingAddDataSheet = false
                    }
                }
            }
        }
    }
    
    private func addHealthData(for date: Date, value: Double) async throws {
        switch healthMetric {
        case .steps:
            try await healthKitManager.addHealthMetricData(for: date, value: value, type: HKQuantityType(.stepCount))
            try await healthKitManager.fetchStepCount()
        default:
            try await healthKitManager.addHealthMetricData(for: date, value: value, type: HKQuantityType(.activeEnergyBurned))
            try await healthKitManager.fetchCalories()
        }
    }
    
    private func handleError(_ error: HCError?) {
        if let error = error, case .sharingDenied(let quantityType) = error {
            writeError = .sharingDenied(quantityType: quantityType)
        } else {
            writeError = .unableToCompleteRequest
        }
        isShowingAlert = true
        isShowingAddDataSheet = true
    }
}

#Preview {
    NavigationStack {
        HealthDataListView(healthMetric: .calories)
            .environment(HealthKitManager())
    }
}
