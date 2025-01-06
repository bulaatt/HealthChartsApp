//
//  HealthDataListView.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 02.01.2025.
//

import SwiftUI

struct HealthDataListView: View {
    
    @Environment(HealthKitManager.self) private var healthKitManager
    @State private var isShowingAddDataSheet: Bool = false
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        // soon will be done 🧃
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
}

#Preview {
    NavigationStack {
        HealthDataListView(healthMetric: .calories)
            .environment(HealthKitManager())
    }
}
