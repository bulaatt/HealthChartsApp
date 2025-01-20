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
    @State private var selectedTab = "Steps"
    private var tabColor: Color {
        switch selectedTab {
        case "Steps": .mint
        case "Calories": .orange
        default: .gray
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            StepChartsView()
                .tabItem {
                    Label("Steps", systemImage: "figure.walk")
                }
                .tag("Steps")
            
            CalorieChartsView()
                .tabItem {
                    Label("Calories", systemImage: "flame")
                }
                .tag("Calories")
        }
        .tint(tabColor)
    }
}

#Preview {
    HealthChartsView()
        .environment(HealthKitManager())
}
