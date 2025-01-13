//
//  Array+Ext.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 12.01.2025.
//

import Foundation

extension Array where Element == Double {
    var average: Double {
        guard !self.isEmpty else { return 0 }
        let total = self.reduce(0, +)
        return total / Double(self.count)
    }
}
