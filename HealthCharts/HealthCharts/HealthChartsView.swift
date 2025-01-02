//
//  HealthChartsView.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 01.01.2025.
//

import SwiftUI

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
                    VStack {
                        NavigationLink(value: selectedHealthMetric) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Label("Steps", systemImage: "figure.hiking")
                                        .font(.title3.bold())
                                        .foregroundStyle(.mint)
                                    
                                    Text("Avg: 12K steps")
                                        .font(.caption)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right.circle")
                                    .imageScale(.large)
                            }
                        }
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 12)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 150)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    
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
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 260)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
            }
            .padding()
            .scrollIndicators(.hidden)
            .onAppear { isShowingPermissionPrimingSheet = !hasSeenPermissionPriming }
            .navigationTitle("Health Charts")
            .navigationDestination(for: HealthMetricContext.self) { healthMetric in
                Text(healthMetric.title)
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
