import SwiftUI
import EventKit

struct ContentView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.modelContext) var context // SwiftData context
    
    var body: some View {
        NavigationView {
            List {
                if(calendarManager.favoriteCalendars.count > 0) {
                    // Favorisierte Kalender anzeigen
                    Section(header: Text("Favorite Calendars")) {
                        ForEach(calendarManager.calendars.filter { calendar in
                            $calendarManager.favoriteCalendars.contains { favoriteCalendar in
                                let identifier: String = calendar.calendarIdentifier // Stelle sicher, dass dies ein String ist
                                return favoriteCalendar.calendarIdentifier.wrappedValue == identifier
                            }
                        }, id: \.self) { calendar in
                            NavigationLink(destination: CalendarView(calendar: calendar)) {
                                CalendarRow(calendar: calendar)
                                    .swipeActions {
                                        // Aus Favoriten entfernen
                                        Button(role: .destructive) {
                                            calendarManager.removeCalendarFromFavorites(calendar, context: context)
                                        } label: {
                                            Label("Unfavorite", systemImage: "star.slash")
                                        }
                                        .tint(Color.yellow)
                                    }
                            }
                        }
                    }
                }
                
                // Alle Kalender anzeigen
                Section(header: Text("All Calendars")) {
                    ForEach(calendarManager.calendars, id: \.self) { calendar in
                        NavigationLink(destination: CalendarView(calendar: calendar)) {
                            CalendarRow(calendar: calendar)
                        }
                        .swipeActions {
                            if calendarManager.favoriteCalendars.contains(where: { $0.calendarIdentifier == calendar.calendarIdentifier }) {
                                // Aus Favoriten entfernen
                                Button(role: .destructive) {
                                    calendarManager.removeCalendarFromFavorites(calendar, context: context)
                                } label: {
                                    Label("Unfavorite", systemImage: "star.slash")
                                }
                                .tint(Color.yellow)
                            } else {
                                // Zu Favoriten hinzufügen
                                Button {
                                    calendarManager.addCalendarToFavorites(calendar, context: context)
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                                .tint(Color.yellow)
                            }
                        }
                    }
                }
            }
            .onAppear {
                calendarManager.loadCalendarEntries(context: context)
                calendarManager.loadFavoriteCalendars(context: context)
            }
            .navigationTitle("Calendars")
        }
    }
}
