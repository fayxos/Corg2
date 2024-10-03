import SwiftUI
import EventKit
import SwiftData

struct CalendarView: View {
    var calendar: EKCalendar
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.modelContext) var context // SwiftData context
    
    @State private var selection = Set<CalendarEntry>()
    @State private var weekSelection = 0

    
    var body: some View {
        VStack {
            // Kalenderheader mit Titel und Farbe
            HStack {
                Circle()
                    .fill(Color(calendar.cgColor))
                    .frame(width: 20, height: 20)
                
                Text(calendar.title)
                    .font(.largeTitle)
                
                Spacer()
                
                Button(action: {
                    if $calendarManager.favoriteCalendars.contains(where: { $0.calendarIdentifier.wrappedValue == calendar.calendarIdentifier }) {
                        calendarManager.removeCalendarFromFavorites(calendar, context: context)
                    } else {
                        calendarManager.addCalendarToFavorites(calendar, context: context)
                    }
                }) {
                    Image(systemName: $calendarManager.favoriteCalendars.contains(where: { $0.calendarIdentifier.wrappedValue == calendar.calendarIdentifier }) ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            
            List(calendarManager.calendarEntries.filter { $0.calendar == calendar.calendarIdentifier }.sorted(by: {
                let calendar = Calendar.current
                if $0.weekday.number != $1.weekday.number {
                    return $0.weekday.number < $1.weekday.number
                } else if calendar.component(.hour, from: $0.startTime) != calendar.component(.hour, from: $1.startTime) {
                    return calendar.component(.hour, from: $0.startTime) < calendar.component(.hour, from: $1.startTime)
                } else if calendar.component(.minute, from: $0.startTime) != calendar.component(.minute, from: $1.startTime) {
                    return calendar.component(.minute, from: $0.startTime) < calendar.component(.minute, from: $1.startTime)
                } else if calendar.component(.hour, from: $0.endTime) != calendar.component(.hour, from: $1.endTime) {
                    return calendar.component(.hour, from: $0.endTime) < calendar.component(.hour, from: $1.endTime)
                } else {
                    return calendar.component(.minute, from: $0.endTime) < calendar.component(.minute, from: $1.endTime)
                }
                     }), id: \.self, selection: $selection) { entry in
                    EntryTile(entry: entry)
                        .swipeActions {
                            Button {
                                context.delete(entry)
                                saveContext(context)
                                calendarManager.calendarEntries = calendarManager.calendarEntries.filter({
                                    $0.id != entry.id
                                })
                            } label: {
                                Image(systemName: "trash")
                            }
                            .tint(Color.red)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                duplicateEntry(entry: entry)
                            } label: {
                                Image(systemName: "document.on.document.fill")
                            }
                            .tint(.blue)
                        }
                        .onAppear {
                            print("\(entry.weekday.number)\(Calendar.current.dateComponents([.hour, .minute], from: entry.startTime))")
                        }
            }
            .toolbar {
                EditButton()
            }
            
            if calendarManager.calendarEntries.filter({ $0.calendar == calendar.calendarIdentifier }).count > 0 {
                Picker("Select a week", selection: $weekSelection) {
                    Text("This week").tag(0)
                    Text("Next week").tag(1)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(.bottom, 20)
                
                Button {
                    if selection.isEmpty {
                        calendarManager.addEventsToCalendar(to: calendar, week: weekSelection, selection: nil)
                    } else {
                        calendarManager.addEventsToCalendar(to: calendar, week: weekSelection, selection: selection)
                    }
                } label: {
                    Text("Add to calendar")
                }
                .padding(.bottom, 20)
            }
            
        }
        .toolbar {
            if !selection.isEmpty {
                ToolbarItem {
                    Button(action: deleteSelection) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        
        }
    }
    
    private func addItem() {
        withAnimation {
            let newEntry = CalendarEntry(name: "", weekday: .monday, startTime: .now, endTime: .now, location: "", calendar: calendar.calendarIdentifier)
            context.insert(newEntry)
            calendarManager.calendarEntries.append(newEntry)
            saveContext(context)
        }
    }
    
    private func duplicateEntry(entry: CalendarEntry) {
        withAnimation {
            let newEntry = CalendarEntry(name: entry.name, weekday: entry.weekday, startTime: entry.startTime, endTime: entry.endTime, location: entry.location, calendar: entry.calendar)
            context.insert(newEntry)
            calendarManager.calendarEntries.append(newEntry)
            saveContext(context)
        }
    }
    
    private func deleteSelection() {
        withAnimation {
            selection.forEach { entry in
                context.delete(entry)
            }
            
            calendarManager.calendarEntries = calendarManager.calendarEntries.filter({ entry in
                !selection.contains(where: { $0.id == entry.id })
            })
            
            selection.removeAll()
            
            saveContext(context)
        }
    }
    
    private func saveContext(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
