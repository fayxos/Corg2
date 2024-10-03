import Foundation
import SwiftData

@Model
final class FavoriteCalendar: Identifiable {
    var calendarIdentifier: String
    
    init(calendarIdentifier: String) {
        self.calendarIdentifier = calendarIdentifier
    }
}
