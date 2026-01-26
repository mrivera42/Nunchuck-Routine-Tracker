//
//  PracticeHeatmapView.swift
//  Nunchuck Routine Tracker
//
//  Created by Max Rivera on 1/22/26.
//

import SwiftUI

struct PracticeHeatmapView: View {
    let practiceDates: Set<Date>
    let attemptCounts: [Date: Int] // Date -> number of attempts that day
    
    @State private var selectedDate: Date?
    @State private var showingDetail = false
    
    private let calendar = Calendar.current
    private let columns = 7 // Days of week
    private let cellSize: CGFloat = 14
    private let cellSpacing: CGFloat = 3
    
    // Get the last 12 weeks of data (like GitHub shows ~52 weeks, but we'll start with 12)
    private var weeks: [[Date?]] {
        let today = Date()
        let endDate = calendar.startOfDay(for: today)
        
        // Go back 12 weeks
        guard let startDate = calendar.date(byAdding: .weekOfYear, value: -11, to: endDate) else {
            return []
        }
        
        // Find the most recent Sunday (or first day of week)
        var currentDate = endDate
        while calendar.component(.weekday, from: currentDate) != 1 { // 1 = Sunday
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        // Find the Sunday before start date
        var weekStartDate = startDate
        while calendar.component(.weekday, from: weekStartDate) != 1 {
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: weekStartDate) else { break }
            weekStartDate = previousDay
        }
        
        // Build weeks array
        var weeksArray: [[Date?]] = []
        var currentWeekStart = weekStartDate
        
        while currentWeekStart <= currentDate {
            var week: [Date?] = []
            for dayOffset in 0..<7 {
                if let day = calendar.date(byAdding: .day, value: dayOffset, to: currentWeekStart) {
                    if day <= endDate && day >= weekStartDate {
                        week.append(day)
                    } else {
                        week.append(nil)
                    }
                } else {
                    week.append(nil)
                }
            }
            weeksArray.append(week)
            
            guard let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) else { break }
            currentWeekStart = nextWeek
        }
        
        return weeksArray
    }
    
    private var monthLabels: [(offset: Int, label: String)] {
        var labels: [(offset: Int, label: String)] = []
        var seenMonths: Set<Int> = []
        
        for (weekIndex, week) in weeks.enumerated() {
            if let firstDay = week.first(where: { $0 != nil }), let date = firstDay {
                let month = calendar.component(.month, from: date)
                if !seenMonths.contains(month) {
                    seenMonths.insert(month)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM"
                    labels.append((offset: weekIndex, label: formatter.string(from: date)))
                }
            }
        }
        
        return labels
    }
    
    private func intensity(for date: Date) -> Int {
        let dayStart = calendar.startOfDay(for: date)
        guard let count = attemptCounts[dayStart] else { return 0 }
        
        // Define intensity levels based on attempt count
        if count == 0 { return 0 }
        else if count <= 5 { return 1 }
        else if count <= 15 { return 2 }
        else if count <= 30 { return 3 }
        else { return 4 }
    }
    
    private func color(for intensity: Int) -> Color {
        switch intensity {
        case 0: return Color.gray.opacity(0.1)
        case 1: return Color.blue.opacity(0.3)
        case 2: return Color.blue.opacity(0.5)
        case 3: return Color.blue.opacity(0.7)
        case 4: return Color.blue
        default: return Color.gray.opacity(0.1)
        }
    }
    
    private func attemptCount(for date: Date) -> Int {
        let dayStart = calendar.startOfDay(for: date)
        return attemptCounts[dayStart] ?? 0
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            HStack {
                Text("Practice Activity")
                    .font(.system(.headline, design: .monospaced, weight: .bold))
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text("\(practiceDates.count) days practiced")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.gray)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    // Month labels
                    HStack(spacing: 0) {
                        // Space for day labels
                        Color.clear.frame(width: 30)
                        
                        ForEach(monthLabels, id: \.offset) { label in
                            Text(label.label)
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                                .frame(width: CGFloat(calculateMonthWidth(at: label.offset)) * (cellSize + cellSpacing), alignment: .leading)
                        }
                    }
                    .padding(.bottom, 2)
                    
                    HStack(alignment: .top, spacing: 0) {
                        // Day of week labels
                        VStack(alignment: .trailing, spacing: cellSpacing) {
                            Text("S").opacity(0) // Sunday (hidden to align)
                            Text("M")
                            Text("")
                            Text("W")
                            Text("")
                            Text("F")
                            Text("")
                        }
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray)
                        .frame(width: 25)
                        .padding(.trailing, 5)
                        
                        // Heatmap grid
                        HStack(spacing: cellSpacing) {
                            ForEach(Array(weeks.enumerated()), id: \.offset) { weekIndex, week in
                                VStack(spacing: cellSpacing) {
                                    ForEach(Array(week.enumerated()), id: \.offset) { dayIndex, date in
                                        if let date = date {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(color(for: intensity(for: date)))
                                                .frame(width: cellSize, height: cellSize)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .strokeBorder(isToday(date) ? Color.blue : Color.clear, lineWidth: 1.5)
                                                )
                                                .onTapGesture {
                                                    selectedDate = date
                                                    showingDetail = true
                                                }
                                        } else {
                                            Color.clear
                                                .frame(width: cellSize, height: cellSize)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // Legend
            HStack(spacing: 8) {
                Text("Less")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
                
                HStack(spacing: 3) {
                    ForEach(0..<5) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color(for: level))
                            .frame(width: 10, height: 10)
                    }
                }
                
                Text("More")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .sheet(isPresented: $showingDetail) {
            if let date = selectedDate {
                DayDetailSheet(date: date, attemptCount: attemptCount(for: date))
                    .presentationDetents([.height(200)])
            }
        }
    }
    
    private func calculateMonthWidth(at offset: Int) -> Int {
        // Calculate how many weeks until the next month label
        if let nextIndex = monthLabels.firstIndex(where: { $0.offset > offset }) {
            return monthLabels[nextIndex].offset - offset
        }
        return weeks.count - offset
    }
}

struct DayDetailSheet: View {
    let date: Date
    let attemptCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                        .foregroundColor(.blue)
                    Text(date.formatted(.dateTime.weekday(.wide)))
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "figure.martial.arts")
                        .font(.system(size: 40))
                        .foregroundColor(.blue.opacity(0.3))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(attemptCount)")
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                        Text(attemptCount == 1 ? "attempt" : "attempts")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
                )
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

#Preview {
    let calendar = Calendar.current
    var dates = Set<Date>()
    var counts: [Date: Int] = [:]
    
    // Generate sample data
    for i in 0..<70 {
        if Int.random(in: 0...10) > 3 { // 70% chance of practice
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let dayStart = calendar.startOfDay(for: date)
                dates.insert(dayStart)
                counts[dayStart] = Int.random(in: 1...40)
            }
        }
    }
    
    return ScrollView {
        PracticeHeatmapView(practiceDates: dates, attemptCounts: counts)
            .padding()
    }
    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
}
