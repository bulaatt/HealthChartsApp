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
    
    var stepData: [HealthMetric] = []
    var calorieData: [HealthMetric] = []
    
    func fetchStepCount() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: queryPredicate)
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                               options: .cumulativeSum,
                                                               anchorDate: endDate,
                                                               intervalComponents: .init(day: 1))
        do {
            let stepCounts = try await stepsQuery.result(for: store)
            stepData = stepCounts.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        } catch {
            
        }
    }
    
    func fetchCalories() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.activeEnergyBurned), predicate: queryPredicate)
        let caloriesQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                                  options: .mostRecent,
                                                                  anchorDate: endDate,
                                                                  intervalComponents: .init(day: 1))
        do {
            let calories = try await caloriesQuery.result(for: store)
            calorieData = calories.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0)
            }
        } catch {
            
        }
    }
    
    func addStepData(for date: Date, value: Double) async {
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount),
                                          quantity: stepQuantity,
                                          start: date,
                                          end: date)
        try! await store.save(stepSample)
    }
    
    func addCalorieData(for date: Date, value: Double) async {
        let calorieQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: value)
        let calorieSample = HKQuantitySample(type: HKQuantityType(.activeEnergyBurned),
                                             quantity: calorieQuantity,
                                             start: date,
                                             end: date)
        try! await store.save(calorieSample)
    }
}
