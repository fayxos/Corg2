//
//  Weekday.swift
//  Corg2
//
//  Created by Felix Haag on 02.10.24.
//

import Foundation

enum Weekday: String, CaseIterable, Identifiable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }
    
    var number: Int {
        switch self {
        case .monday: return 0
        case .tuesday: return 1
        case .wednesday: return 2
        case .thursday: return 3
        case .friday: return 4
        case .saturday: return 5
        case .sunday: return 6
        }
    }
    
    func nextDay() -> Weekday {
        var newWeekday: Weekday {
            switch self {
            case .monday: return .tuesday
            case .tuesday: return .wednesday
            case .wednesday: return .thursday
            case .thursday: return .friday
            case .friday: return .saturday
            case .saturday: return .sunday
            case .sunday: return .monday
            }
        }
        
        return newWeekday
    }
}

