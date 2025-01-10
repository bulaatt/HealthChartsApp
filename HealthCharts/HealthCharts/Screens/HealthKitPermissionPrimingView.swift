//
//  HealthKitPermissionPrimingView.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 02.01.2025.
//

import SwiftUI
import HealthKitUI

struct HealthKitPermissionPrimingView: View {
    
    @Environment(HealthKitManager.self) var healthKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingHealthPermissions: Bool = false
    @State private var errorMessage: String? = nil
    
    var description = """
    This app displays your step and calorie data in interactive charts.
    
    You can also add new step and calorie data to Apple Health from this app. Your data is private and secure.
    """
    
    var body: some View {
        VStack(spacing: 120) {
            VStack(alignment: .leading, spacing: 14) {
                Image(.appleHealthIcon)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .shadow(color: .gray.opacity(0.4), radius: 16)
                
                Text("Apple Health Integration")
                    .font(.title2).bold()
                
                Text(description)
                    .foregroundStyle(.secondary)
            }
            
            Button("Connect Apple Health") {
                isShowingHealthPermissions = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding(30)
        .interactiveDismissDisabled()
        .alert("HealthKit Access Error", isPresented: .constant(errorMessage != nil), actions: {
            Button("OK", role: .cancel) { errorMessage = nil }
        }, message: {
            Text(errorMessage ?? "An unexpected error occurred.")
        })
        .alert("HealthKit Access Error", isPresented: .constant(errorMessage != nil), actions: {
            Button("OK", role: .cancel) { errorMessage = nil }
        }, message: {
            Text(errorMessage ?? "An unexpected error occurred.")
        })
        .healthDataAccessRequest(store: healthKitManager.store,
                                 shareTypes: healthKitManager.types,
                                 readTypes: healthKitManager.types,
                                 trigger: isShowingHealthPermissions) { result in
            switch result {
            case .success(_):
                dismiss()
            case .failure(let error):
                errorMessage = "Failed to access HealthKit: \(error.localizedDescription)"
                dismiss()
            }
        }
    }
}

#Preview {
    HealthKitPermissionPrimingView()
        .environment(HealthKitManager())
}
