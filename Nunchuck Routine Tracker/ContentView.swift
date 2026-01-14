//
//  ContentView.swift
//  Nunchuck Routine Tracker
//
//  Created by Max Rivera on 1/11/26.
//

import SwiftUI
import Charts

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var store = RoutineStore()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DailyDrillView(store: store)
                .tabItem {
                    Label("Training", systemImage: "figure.martial.arts")
                }
                .tag(0)
            
            AnalyticsView(store: store)
                .tabItem {
                    Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)
        }
        .tint(.blue)
    }
}

struct DailyDrillView: View {
    @Bindable var store: RoutineStore
    @State private var showingAddRoutine = false
    @State private var newRoutineName = ""
    @State private var selectedDiscipline = "Nunchucks"
    
    let disciplines = ["Nunchucks", "Bo Staff", "Kama", "Open Hand"]
    
    private var groupedRoutines: [String: [Routine]] {
        Dictionary(grouping: store.routines, by: { $0.discipline })
    }
    
    private var sortedDisciplines: [String] {
        groupedRoutines.keys.sorted()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Martial Arts Tracker")
                                .font(.system(size: 28, weight: .black, design: .monospaced))
                                .italic()
                                .foregroundColor(.blue)
                            Text(Date().formatted(date: .abbreviated, time: .omitted).uppercased())
                                .font(.system(.subheadline, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(.blue.opacity(0.7))
                            Text("Log your successful and missed attempts when you practice today")
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(Color.white)
                
                if store.routines.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "figure.martial.arts")
                            .font(.system(size: 60))
                            .foregroundColor(.blue.opacity(0.3))
                        Text("No drills yet")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.blue)
                        Button("Add Your First Move") {
                            showingAddRoutine = true
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 24) {
                            ForEach(sortedDisciplines, id: \.self) { discipline in
                                VStack(alignment: .leading, spacing: 12) {
                                    // Discipline header
                                    Text(discipline.uppercased())
                                        .font(.system(size: 12, weight: .black, design: .monospaced))
                                        .foregroundColor(.blue.opacity(0.7))
                                        .padding(.horizontal)
                                    
                                    // Routines for this discipline
                                    ForEach(groupedRoutines[discipline] ?? []) { routine in
                                        RoutineRowView(
                                            routine: routine,
                                            onSuccess: {
                                                store.addAttempt(to: routine, isSuccess: true)
                                                hapticFeedback()
                                            },
                                            onFailure: {
                                                store.addAttempt(to: routine, isSuccess: false)
                                                hapticFeedback()
                                            }
                                        )
                                        .padding(.horizontal)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                store.deleteRoutine(routine)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    showingAddRoutine = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(.title, design: .monospaced, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: .blue.opacity(0.3), radius: 10)
                }
                .padding(25)
            }
            .sheet(isPresented: $showingAddRoutine) {
                NavigationStack {
                    Form {
                        Section("Discipline") {
                            Picker("Type", selection: $selectedDiscipline) {
                                ForEach(disciplines, id: \.self) { discipline in
                                    Text(discipline).tag(discipline)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        Section("Routine Details") {
                            TextField("Routine Name", text: $newRoutineName)
                        }
                    }
                    .navigationTitle("New Routine")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingAddRoutine = false
                                newRoutineName = ""
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                if !newRoutineName.isEmpty {
                                    store.addRoutine(name: newRoutineName, discipline: selectedDiscipline)
                                    newRoutineName = ""
                                    showingAddRoutine = false
                                }
                            }
                            .disabled(newRoutineName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct AnalyticsView: View {
    @Bindable var store: RoutineStore
    @State private var showingShareSheet = false
    @State private var statsImage: UIImage?
    
    private var groupedRoutines: [String: [Routine]] {
        Dictionary(grouping: store.routines, by: { $0.discipline })
    }
    
    private var sortedDisciplines: [String] {
        groupedRoutines.keys.sorted()
    }
    
    private var totalAttempts: Int {
        store.routines.reduce(0) { $0 + $1.attempts.count }
    }
    
    private var totalSuccesses: Int {
        store.routines.reduce(0) { total, routine in
            total + routine.attempts.filter { $0.isSuccess }.count
        }
    }
    
    private var totalMisses: Int {
        store.routines.reduce(0) { total, routine in
            total + routine.attempts.filter { !$0.isSuccess }.count
        }
    }
    
    private var overallSuccessRate: String {
        guard totalAttempts > 0 else { return "0%" }
        let rate = Int((Double(totalSuccesses) / Double(totalAttempts)) * 100)
        return "\(rate)%"
    }
    
    private var allPracticeDates: Set<Date> {
        let calendar = Calendar.current
        var dates = Set<Date>()
        for routine in store.routines {
            for attempt in routine.attempts {
                let day = calendar.startOfDay(for: attempt.date)
                dates.insert(day)
            }
        }
        return dates
    }
    
    private var currentStreak: Int {
        guard !allPracticeDates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = today
        
        while allPracticeDates.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }
        
        return streak
    }
    
    private var longestStreak: Int {
        guard !allPracticeDates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedDates = allPracticeDates.sorted()
        
        var maxStreak = 1
        var currentStreakCount = 1
        
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i - 1]
            let currentDate = sortedDates[i]
            
            if let dayDifference = calendar.dateComponents([.day], from: previousDate, to: currentDate).day,
               dayDifference == 1 {
                currentStreakCount += 1
                maxStreak = max(maxStreak, currentStreakCount)
            } else {
                currentStreakCount = 1
            }
        }
        
        return maxStreak
    }
    
    private var sortedRoutinesBySuccessRate: [(discipline: String, routines: [Routine])] {
        var result: [(discipline: String, routines: [Routine])] = []
        
        for discipline in sortedDisciplines {
            if let routines = groupedRoutines[discipline] {
                let sorted = routines.sorted { routine1, routine2 in
                    let rate1 = successRate(for: routine1)
                    let rate2 = successRate(for: routine2)
                    return rate1 > rate2
                }
                result.append((discipline: discipline, routines: sorted))
            }
        }
        
        return result
    }
    
    private func successRate(for routine: Routine) -> Double {
        guard !routine.attempts.isEmpty else { return 0 }
        let successCount = routine.attempts.filter { $0.isSuccess }.count
        return Double(successCount) / Double(routine.attempts.count) * 100
    }
    
    var body: some View {
        NavigationStack {
            if store.routines.isEmpty {
                ContentUnavailableView(
                    "No Data Yet",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("Start logging attempts to see your progress over time")
                )
            } else {
                List {
                    Section {
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Success Rate",
                                    value: overallSuccessRate,
                                    color: .blue
                                )
                                StatCard(
                                    title: "Total Attempts",
                                    value: "\(totalAttempts)",
                                    color: .blue.opacity(0.7)
                                )
                            }
                            
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Successes",
                                    value: "\(totalSuccesses)",
                                    color: .blue
                                )
                                StatCard(
                                    title: "Misses",
                                    value: "\(totalMisses)",
                                    color: .gray
                                )
                            }
                        }
                        .padding(.vertical, 8)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    } header: {
                        Text("Overall Stats")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.blue)
                            .textCase(nil)
                    }
                    
                    Section {
                        HStack(spacing: 12) {
                            StatCard(
                                title: "Current Streak",
                                value: "\(currentStreak)",
                                color: .blue
                            )
                            StatCard(
                                title: "Longest Streak",
                                value: "\(longestStreak)",
                                color: .blue.opacity(0.7)
                            )
                        }
                        .padding(.vertical, 8)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    } header: {
                        Text("Practice Streaks")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.blue)
                            .textCase(nil)
                    }
                    
                    Section {
                        PracticeCalendarView(practiceDates: allPracticeDates)
                            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    } header: {
                        Text("Practice Calendar")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.blue)
                            .textCase(nil)
                    }
                    
                    ForEach(sortedRoutinesBySuccessRate, id: \.discipline) { group in
                        Section(group.discipline) {
                            ForEach(Array(group.routines.enumerated()), id: \.element.id) { index, routine in
                                NavigationLink {
                                    RoutineDetailView(routine: routine)
                                } label: {
                                    RoutineAnalyticsRow(routine: routine, rank: index + 1)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Analytics")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            generateStatsReport()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(.body, design: .monospaced, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .sheet(isPresented: $showingShareSheet) {
                    if let image = statsImage {
                        ShareSheet(items: [image])
                    } else {
                        // Fallback to text summary
                        ShareSheet(items: [generateTextSummary()])
                    }
                }
            }
        }
    }
    
    private func generateStatsReport() {
        // Create the report view
        let reportView = StatsReportView(
            store: store,
            totalAttempts: totalAttempts,
            totalSuccesses: totalSuccesses,
            totalMisses: totalMisses,
            overallSuccessRate: overallSuccessRate,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            practiceDates: allPracticeDates,
            sortedRoutines: sortedRoutinesBySuccessRate
        )
        
        // Calculate height
        let baseHeight: CGFloat = 800
        let routineHeight: CGFloat = CGFloat(sortedRoutinesBySuccessRate.reduce(0) { $0 + min($1.routines.count, 5) }) * 40
        let totalHeight = baseHeight + routineHeight
        
        // Use ImageRenderer with proposed size
        let renderer = ImageRenderer(content: reportView)
        renderer.proposedSize = ProposedViewSize(width: 600, height: totalHeight)
        renderer.scale = 3.0
        
        // Generate image on main thread with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let image = renderer.uiImage {
                self.statsImage = image
                self.showingShareSheet = true
            } else {
                print("Failed to generate image")
                // Show share sheet anyway with text fallback
                self.showingShareSheet = true
            }
        }
    }
    
    private func generateTextSummary() -> String {
        var summary = """
        MARTIAL ARTS TRAINING REPORT
        \(Date().formatted(date: .long, time: .omitted))
        
        OVERALL PERFORMANCE
        • Success Rate: \(overallSuccessRate)
        • Total Attempts: \(totalAttempts)
        • Successes: \(totalSuccesses)
        • Misses: \(totalMisses)
        
        PRACTICE STREAKS
        • Current Streak: \(currentStreak) days
        • Longest Streak: \(longestStreak) days
        
        ROUTINES BY SUCCESS RATE
        
        """
        
        for group in sortedRoutinesBySuccessRate {
            summary += "\n\(group.discipline.uppercased())\n"
            for (index, routine) in group.routines.prefix(5).enumerated() {
                let rate = successRate(for: routine)
                summary += "#\(index + 1) \(routine.name) - \(Int(rate))% (\(routine.attempts.count) attempts)\n"
            }
        }
        
        summary += "\n---\nGenerated by Martial Arts Tracker"
        return summary
    }
}

struct RoutineAnalyticsRow: View {
    let routine: Routine
    var rank: Int? = nil
    
    private var accuracy: Int {
        guard !routine.attempts.isEmpty else { return 0 }
        let successCount = routine.attempts.filter { $0.isSuccess }.count
        let totalCount = routine.attempts.count
        return Int((Double(successCount) / Double(totalCount)) * 100)
    }
    
    private var rankBadgeColor: Color {
        guard let rank = rank else { return .blue }
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
    
    var body: some View {
        HStack {
            if let rank = rank {
                ZStack {
                    Circle()
                        .fill(rankBadgeColor.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Text("#\(rank)")
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundColor(rankBadgeColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.name)
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(.blue)
                if !routine.attempts.isEmpty {
                    Text("\(routine.attempts.count) attempts")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            
            if !routine.attempts.isEmpty {
                Text("\(accuracy)%")
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                    .foregroundColor(.blue)
            }
        }
    }
}

struct RoutineDetailView: View {
    let routine: Routine
    
    private var successRateText: String {
        guard !routine.attempts.isEmpty else { return "0%" }
        let successCount = routine.attempts.filter { $0.isSuccess }.count
        let totalCount = routine.attempts.count
        let rate = Int((Double(successCount) / Double(totalCount)) * 100)
        return "\(rate)%"
    }
    
    private var dailySuccessRates: [(date: Date, rate: Double)] {
        let calendar = Calendar.current
        var dailyData: [Date: (success: Int, total: Int)] = [:]
        
        for attempt in routine.attempts {
            let day = calendar.startOfDay(for: attempt.date)
            if dailyData[day] == nil {
                dailyData[day] = (0, 0)
            }
            dailyData[day]?.total += 1
            if attempt.isSuccess {
                dailyData[day]?.success += 1
            }
        }
        
        return dailyData.map { (date: $0.key, rate: Double($0.value.success) / Double($0.value.total) * 100) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Overall Stats
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        StatCard(
                            title: "Success Rate",
                            value: successRateText,
                            color: .blue
                        )
                        StatCard(
                            title: "Total Attempts",
                            value: "\(routine.attempts.count)",
                            color: .blue.opacity(0.7)
                        )
                    }
                    
                    HStack(spacing: 20) {
                        StatCard(
                            title: "Successes",
                            value: "\(routine.attempts.filter { $0.isSuccess }.count)",
                            color: .blue
                        )
                        StatCard(
                            title: "Misses",
                            value: "\(routine.attempts.filter { !$0.isSuccess }.count)",
                            color: .gray
                        )
                    }
                }
                .padding()
                
                // Progress Chart
                if dailySuccessRates.count >= 2 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Success Rate Over Time")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.blue)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(dailySuccessRates, id: \.date) { data in
                                LineMark(
                                    x: .value("Date", data.date, unit: .day),
                                    y: .value("Success Rate", data.rate)
                                )
                                .foregroundStyle(.blue)
                                .interpolationMethod(.catmullRom)
                                
                                PointMark(
                                    x: .value("Date", data.date, unit: .day),
                                    y: .value("Success Rate", data.rate)
                                )
                                .foregroundStyle(.blue)
                            }
                        }
                        .chartYScale(domain: 0...100)
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisValueLabel {
                                    if let intValue = value.as(Double.self) {
                                        Text("\(Int(intValue))%")
                                    }
                                }
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.blue)
                                AxisGridLine()
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { _ in
                                AxisValueLabel(format: .dateTime.month().day())
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.blue)
                                AxisGridLine()
                            }
                        }
                        .frame(height: 250)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                        )
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                
                // Recent History
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent History")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                    
                    ForEach(routine.attempts.reversed().prefix(20)) { attempt in
                        HStack {
                            Image(systemName: attempt.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(attempt.isSuccess ? .blue : .gray)
                            Text(attempt.isSuccess ? "Success" : "Miss")
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.blue)
                            Spacer()
                            Text(attempt.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(routine.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(.title, design: .monospaced, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
    }
}

struct PracticeCalendarView: View {
    let practiceDates: Set<Date>
    @State private var currentMonth = Date()
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth).uppercased()
    }
    
    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }
    
    private var firstWeekday: Int {
        guard let firstDay = daysInMonth.first else { return 0 }
        return calendar.component(.weekday, from: firstDay) - 1
    }
    
    private func isPracticeDay(_ date: Date) -> Bool {
        let day = calendar.startOfDay(for: date)
        return practiceDates.contains(day)
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Month navigation
            HStack {
                Button {
                    if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
                        currentMonth = newMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(.body, design: .monospaced, weight: .bold))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.system(.subheadline, design: .monospaced, weight: .bold))
                    .foregroundColor(.blue)
                
                Spacer()
                
                Button {
                    if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
                        currentMonth = newMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(.body, design: .monospaced, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
            
            // Day labels
            HStack(spacing: 8) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(.caption2, design: .monospaced, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                // Empty cells for padding
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Circle()
                        .fill(Color.clear)
                        .frame(height: 32)
                }
                
                // Days of month
                ForEach(daysInMonth, id: \.self) { date in
                    ZStack {
                        Circle()
                            .fill(isPracticeDay(date) ? Color.blue : Color.gray.opacity(0.15))
                            .frame(height: 32)
                        
                        if isToday(date) {
                            Circle()
                                .stroke(Color.blue, lineWidth: 2)
                                .frame(height: 32)
                        }
                        
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(.caption, design: .monospaced, weight: .semibold))
                            .foregroundColor(isPracticeDay(date) ? .white : .gray)
                    }
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 12, height: 12)
                    Text("Practiced")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: 12, height: 12)
                    Text("Today")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
    }
}

struct StatsReportView: View {
    let store: RoutineStore
    let totalAttempts: Int
    let totalSuccesses: Int
    let totalMisses: Int
    let overallSuccessRate: String
    let currentStreak: Int
    let longestStreak: Int
    let practiceDates: Set<Date>
    let sortedRoutines: [(discipline: String, routines: [Routine])]
    
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date()).uppercased()
    }
    
    private func successRate(for routine: Routine) -> Int {
        guard !routine.attempts.isEmpty else { return 0 }
        let successCount = routine.attempts.filter { $0.isSuccess }.count
        return Int((Double(successCount) / Double(routine.attempts.count)) * 100)
    }
    
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Martial Arts Training Report")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                    Text(currentDate)
                        .font(.system(.subheadline, design: .monospaced, weight: .bold))
                        .foregroundColor(.blue.opacity(0.7))
                }
                .padding(.top, 40)
                
                // Overall Stats Grid
                VStack(spacing: 12) {
                    Text("OVERALL PERFORMANCE")
                        .font(.system(.caption, design: .monospaced, weight: .black))
                        .foregroundColor(.blue.opacity(0.7))
                    
                    HStack(spacing: 12) {
                        MiniStatCard(title: "Success Rate", value: overallSuccessRate, color: .blue)
                        MiniStatCard(title: "Total Attempts", value: "\(totalAttempts)", color: .blue.opacity(0.7))
                    }
                    HStack(spacing: 12) {
                        MiniStatCard(title: "Successes", value: "\(totalSuccesses)", color: .blue)
                        MiniStatCard(title: "Misses", value: "\(totalMisses)", color: .gray)
                    }
                }
                
                // Streaks
                VStack(spacing: 12) {
                    Text("PRACTICE STREAKS")
                        .font(.system(.caption, design: .monospaced, weight: .black))
                        .foregroundColor(.blue.opacity(0.7))
                    
                    HStack(spacing: 12) {
                        MiniStatCard(title: "Current", value: "\(currentStreak) days", color: .blue)
                        MiniStatCard(title: "Longest", value: "\(longestStreak) days", color: .blue.opacity(0.7))
                    }
                }
                
                // Routines by Discipline
                VStack(alignment: .leading, spacing: 16) {
                    Text("TOP ROUTINES BY SUCCESS RATE")
                        .font(.system(.caption, design: .monospaced, weight: .black))
                        .foregroundColor(.blue.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    ForEach(sortedRoutines, id: \.discipline) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(group.discipline.uppercased())
                                .font(.system(.caption2, design: .monospaced, weight: .black))
                                .foregroundColor(.blue.opacity(0.6))
                            
                            ForEach(Array(group.routines.prefix(3).enumerated()), id: \.element.id) { index, routine in
                                HStack {
                                    Text("#\(index + 1)")
                                        .font(.system(.caption2, design: .monospaced, weight: .bold))
                                        .foregroundColor(.gray)
                                        .frame(width: 30, alignment: .leading)
                                    
                                    Text(routine.name)
                                        .font(.system(.caption, design: .monospaced, weight: .semibold))
                                        .foregroundColor(.blue)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Text("\(successRate(for: routine))%")
                                        .font(.system(.caption, design: .monospaced, weight: .bold))
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Footer
                Text("Generated by Martial Arts Tracker")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .frame(width: 600)
    }
}

struct MiniStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title.uppercased())
                .font(.system(.caption2, design: .monospaced, weight: .bold))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(.title2, design: .monospaced, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
    }
}

struct CompactCalendarView: View {
    let practiceDates: Set<Date>
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var daysInMonth: [Date] {
        let currentMonth = Date()
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }
    
    private var firstWeekday: Int {
        guard let firstDay = daysInMonth.first else { return 0 }
        return calendar.component(.weekday, from: firstDay) - 1
    }
    
    private func isPracticeDay(_ date: Date) -> Bool {
        let day = calendar.startOfDay(for: date)
        return practiceDates.contains(day)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Day labels
            HStack(spacing: 6) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(.caption2, design: .monospaced, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Circle()
                        .fill(Color.clear)
                        .frame(height: 24)
                }
                
                ForEach(daysInMonth, id: \.self) { date in
                    Circle()
                        .fill(isPracticeDay(date) ? Color.blue : Color.gray.opacity(0.15))
                        .frame(height: 24)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
        .preferredColorScheme(.light)
}
