//
//  HealthKitManager.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 02.01.2025.
//

import Foundation
import HealthKit
import Observation

@Observable class HealthKitManager {
    let store = HKHealthStore()
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.activeEnergyBurned)]
}
