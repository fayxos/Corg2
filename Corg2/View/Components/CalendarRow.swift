//
//  CalendarRow.swift
//  Corg2
//
//  Created by Felix Haag on 03.10.24.
//

import SwiftUI
import EventKit

struct CalendarRow: View {
    var calendar: EKCalendar
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(calendar.cgColor))
                .frame(width: 20, height: 20)
            
            Text(calendar.title)
                .font(.headline)
            
            Spacer()
            
            if calendarManager.calendarEntries.filter({ $0.calendar == calendar.calendarIdentifier }).count > 0{
                Text("\(calendarManager.calendarEntries.filter{ $0.calendar == calendar.calendarIdentifier }.count)")
            }
            
        }
    }
}
