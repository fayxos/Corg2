import SwiftData
import Foundation

@Model
final class CalendarEntry : ObservableObject {
    var name: String
    var weekday: Weekday
    var startTime: Date
    var endTime: Date
    var location: String
    @Relationship var calendar: String // Identifier for the calendar this entry belongs to
    
    init(name: String, weekday: Weekday, startTime: Date, endTime: Date, location: String, calendar: String) {
        self.name = name
        self.weekday = weekday
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.calendar = calendar
    }
}
