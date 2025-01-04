//
//  Date+Ext.swift
//  HealthCharts
//
//  Created by Булат Камалетдинов on 04.01.2025.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
}
