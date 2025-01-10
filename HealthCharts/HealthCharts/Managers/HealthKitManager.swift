//
//  HealthKitManager.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 02.01.2025.
//

import Foundation
import HealthKit
import Observation

enum HCError: LocalizedError {
    case authNotDetermined
    case sharingDenied(quantityType: String)
    case noData
    case unableToCompleteRequest
    
    var errorDescription: String? {
        switch self {
        case .authNotDetermined:
            "Need Access for Health Data"
        case .sharingDenied(quantityType: let quantityType):
            "Sharing Denied for \(quantityType)"
        case .noData:
            "No data"
        case .unableToCompleteRequest:
            "Unable to complete request"
        }
    }
    
    var failureReason: String {
        switch self {
        case .authNotDetermined:
            "You have not given access to your Health data. Please go to Settings -> Health -> Data Access & Devices."
        case .sharingDenied(quantityType: let quantityType):
            "You have denied access for \(quantityType).\n\nYou can change this in Settings -> Health -> Data Access & Devices."
        case .noData:
            "There is no data for this Health statistic."
        case .unableToCompleteRequest:
            "We are unable to complete your request at this time.\n\nPlease try again later or contact support."
        }
    }
}

@Observable class HealthKitManager {
    let store = HKHealthStore()
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.activeEnergyBurned)]
    
    var stepData: [HealthMetric] = []
    var calorieData: [HealthMetric] = []
    
    func fetchStepCount() async throws {
        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            throw HCError.authNotDetermined
        }
        
        let (startDate, endDate) = getDateRange()
        
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
        } catch HKError.errorNoData {
            throw HCError.noData
        } catch {
            throw HCError.unableToCompleteRequest
        }
    }
    
    func fetchCalories() async throws {
        guard store.authorizationStatus(for: HKQuantityType(.activeEnergyBurned)) != .notDetermined else {
            throw HCError.authNotDetermined
        }
        
        let (startDate, endDate) = getDateRange()
        
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
        } catch HKError.errorNoData {
            throw HCError.noData
        } catch {
            throw HCError.unableToCompleteRequest
        }
    }
    
    func addHealthMetricData(for date: Date, value: Double, type: HKQuantityType) async throws {
        let status = store.authorizationStatus(for: type)
        
        var sharingDeniedMessage: String
        
        switch type {
        case HKQuantityType(.stepCount):
            sharingDeniedMessage = "Steps"
        case HKQuantityType(.activeEnergyBurned):
            sharingDeniedMessage = "Calories"
        default:
            sharingDeniedMessage = "Health Metric"
        }
        
        switch status {
        case .notDetermined:
            throw HCError.authNotDetermined
        case .sharingDenied:
            throw HCError.sharingDenied(quantityType: sharingDeniedMessage)
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        let quantity: HKQuantity
        let sample: HKQuantitySample
        
        switch type {
        case HKQuantityType(.stepCount):
            quantity = HKQuantity(unit: .count(), doubleValue: value)
            sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        case HKQuantityType(.activeEnergyBurned):
            quantity = HKQuantity(unit: .kilocalorie(), doubleValue: value)
            sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        default:
            throw HCError.unableToCompleteRequest
        }
        
        do {
            try await store.save(sample)
        } catch {
            throw HCError.unableToCompleteRequest
        }
    }
    
    private func getDateRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!
        return (startDate, endDate)
    }
}
