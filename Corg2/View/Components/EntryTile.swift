import SwiftUI

struct EntryTile: View {
    @Environment(\.modelContext) var context // SwiftData context
    @ObservedObject var entry: CalendarEntry
    
    var body: some View {
        VStack {
            HStack {
                TextField("Name", text: $entry.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: entry.name) { saveChanges() }
                
                TextField("Location", text: $entry.location)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: entry.location) { saveChanges() }
            }.padding(.bottom, 10)
            
            HStack {
                
                Picker("", selection: $entry.weekday) {
                    ForEach(Weekday.allCases) { weekday in
                        Text(weekday.displayName).tag(weekday)
                    }
                }
                .onChange(of: entry.weekday) { saveChanges() }
                
                DatePicker("", selection: $entry.startTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .onChange(of: entry.startTime) { saveChanges() }
                                
                Text("-")
                                
                DatePicker("", selection: $entry.endTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                .onChange(of: entry.endTime) { saveChanges() }
              }
        }
    }
    
    private func saveChanges() {
        do {
            try context.save()
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
}
