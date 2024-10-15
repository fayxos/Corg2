import EventKit
import SwiftData

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var calendars: [EKCalendar] = []
    @Published var favoriteCalendars: [FavoriteCalendar] = []
    @Published var calendarEntries: [CalendarEntry] = []

    init() {
        // Initialisiere die Kalenderliste und lade die Favoriten aus der Datenbank
        requestAccess()
    }
    
    // MARK: - Request Access
    private func requestAccess() {
        eventStore.requestAccess(to: .event) { [weak self] (granted, error) in
            if granted {
                self?.fetchAllCalendars()
            } else {
                print("Access to calendar was denied or an error occurred: \(String(describing: error))")
            }
        }
    }
    
    // MARK: - Fetch All Calendars
    func fetchAllCalendars() {
        calendars = eventStore.calendars(for: .event)
    }
    
    // MARK: - Fetch Events for a Specific Calendar
    func fetchEvents(for calendar: EKCalendar, name: String, startDate: Date, endDate: Date) -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
        return eventStore.events(matching: predicate).filter({ $0.title == name })
    }
    
    // MARK: - Add Event to Calendar
    func addEvent(to calendar: EKCalendar, title: String, location: String, startDate: Date, endDate: Date) {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.location = location
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = calendar
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Event successfully added to calendar.")
        } catch {
            print("Failed to add event to calendar: \(error)")
        }
    }
    
    func addEntryToCalendar(entry: CalendarEntry, to calendar: EKCalendar, week: Int) {
        let startDate = getDateFromWeekAndTime(week: week, weekday: entry.weekday, time: entry.startTime)!
        
        // Check if entry goes up to next day
        var weekday = entry.weekday
        if entry.endTime < entry.startTime {
            weekday = weekday.nextDay()
        }
        let endDate = getDateFromWeekAndTime(week: week, weekday: weekday, time: entry.endTime)!
                
        if fetchEvents(for: calendar, name: entry.name, startDate: startDate, endDate: endDate).isEmpty {
            addEvent(to: calendar, title: entry.name, location: entry.location, startDate: startDate, endDate: endDate)
        }
    }
    
    func addEventsToCalendar(to calendar: EKCalendar, week: Int, selection: Set<CalendarEntry>?) {
        if let entries = selection {
            entries.forEach { entry in
                addEntryToCalendar(entry: entry, to: calendar, week: week)
            }
        } else {
            calendarEntries.filter({ $0.calendar == calendar.calendarIdentifier }).forEach { entry in
                addEntryToCalendar(entry: entry, to: calendar, week: week)
            }
        }
    }
    
    func getDateFromWeekAndTime(week: Int, weekday: Weekday, time: Date) -> Date? {
        // Get the current calendar and set the locale and time zone
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "de_DE") // German locale
        calendar.timeZone = TimeZone.current

        // Get the current date and time
        let now = Date()
        
        // Get the start of the current week (assuming the week starts on Monday)
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return nil
        }

        // Calculate the target week by adding the specified number of weeks to the start of the current week
        guard let targetWeekStartDate = calendar.date(byAdding: .weekOfYear, value: week, to: startOfWeek) else {
            return nil
        }
        
        // Calculate the number of days to add based on the specified weekday
        let targetWeekdayOffset = weekday.number - calendar.component(.weekday, from: targetWeekStartDate) + 2
        
        // Calculate the target day by adding the target weekday offset to the start of the target week
        guard let targetDay = calendar.date(byAdding: .day, value: targetWeekdayOffset, to: targetWeekStartDate) else {
            return nil
        }
        
        // Extract the hour, minute, and second components from the input time
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        // Combine the target day and time components to get the final date
        guard let targetDateWithTime = calendar.date(bySettingHour: timeComponents.hour ?? 0, minute: timeComponents.minute ?? 0, second: 0, of: targetDay) else {
            return nil
        }
        
        return targetDateWithTime
    }

    
    // MARK: - Save CalendarEntry to SwiftData
    func saveCalendarEntry(_ entry: CalendarEntry, context: ModelContext) {
        context.insert(entry)
        do {
            try context.save()
        } catch {
            print("Failed to save calendar entry: \(error)")
        }
    }
    
    // MARK: - Load and Save Favorite Calendars
    func loadFavoriteCalendars(context: ModelContext) {
        do {
            favoriteCalendars = try context.fetch(FetchDescriptor<FavoriteCalendar>())
        } catch {}
    }

    func addCalendarToFavorites(_ calendar: EKCalendar, context: ModelContext) {
        guard !favoriteCalendars.contains(where: { $0.calendarIdentifier == calendar.calendarIdentifier }) else { return }

        let favorite = FavoriteCalendar(calendarIdentifier: calendar.calendarIdentifier)
        context.insert(favorite)
        saveContext(context)
        
        favoriteCalendars.append(favorite)
    }
    
    func removeCalendarFromFavorites(_ calendar: EKCalendar, context: ModelContext) {
        if let favorite = favoriteCalendars.first(where: { $0.calendarIdentifier == calendar.calendarIdentifier }) {
            context.delete(favorite)
            saveContext(context)
            
            favoriteCalendars.removeAll(where: { $0.id == favorite.id })
        }
    }
    
    func loadCalendarEntries(context: ModelContext) {
        do {
            calendarEntries = try context.fetch(FetchDescriptor<CalendarEntry>())
        } catch {}
    }
    
    private func saveContext(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
