//
//  HealthChartsApp.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 01.01.2025.
//

import SwiftUI

@main
struct HealthChartsApp: App {
    let healthKitManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            HealthChartsView()
                .environment(healthKitManager)
        }
    }
}
