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
        .tint(.yellow)
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
                                .font(.system(size: 28, weight: .black))
                                .italic()
                                .foregroundColor(.yellow)
                            Text(Date().formatted(date: .abbreviated, time: .omitted).uppercased())
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow.opacity(0.8))
                            Text("Log your successful and missed attempts when you practice today")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 2)
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                
                if store.routines.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "figure.martial.arts")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("No drills yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Button("Add Your First Move") {
                            showingAddRoutine = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemGroupedBackground))
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 24) {
                            ForEach(sortedDisciplines, id: \.self) { discipline in
                                VStack(alignment: .leading, spacing: 12) {
                                    // Discipline header
                                    Text(discipline.uppercased())
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundColor(.yellow.opacity(0.8))
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
                    .background(Color(uiColor: .systemGroupedBackground))
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    showingAddRoutine = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.yellow)
                        .clipShape(Circle())
                        .shadow(radius: 10)
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
                                    color: .yellow
                                )
                                StatCard(
                                    title: "Total Attempts",
                                    value: "\(totalAttempts)",
                                    color: .orange
                                )
                            }
                            
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Successes",
                                    value: "\(totalSuccesses)",
                                    color: .yellow
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
                            .font(.headline)
                            .foregroundColor(.primary)
                            .textCase(nil)
                    }
                    
                    ForEach(sortedDisciplines, id: \.self) { discipline in
                        Section(discipline) {
                            ForEach(groupedRoutines[discipline] ?? []) { routine in
                                NavigationLink {
                                    RoutineDetailView(routine: routine)
                                } label: {
                                    RoutineAnalyticsRow(routine: routine)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Analytics")
            }
        }
    }
}

struct RoutineAnalyticsRow: View {
    let routine: Routine
    
    private var accuracy: Int {
        guard !routine.attempts.isEmpty else { return 0 }
        let successCount = routine.attempts.filter { $0.isSuccess }.count
        let totalCount = routine.attempts.count
        return Int((Double(successCount) / Double(totalCount)) * 100)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.name)
                    .font(.headline)
                if !routine.attempts.isEmpty {
                    Text("\(routine.attempts.count) attempts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            
            if !routine.attempts.isEmpty {
                Text("\(accuracy)%")
                    .font(.title3.bold())
                    .foregroundColor(.yellow)
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
                            color: .yellow
                        )
                        StatCard(
                            title: "Total Attempts",
                            value: "\(routine.attempts.count)",
                            color: .orange
                        )
                    }
                    
                    HStack(spacing: 20) {
                        StatCard(
                            title: "Successes",
                            value: "\(routine.attempts.filter { $0.isSuccess }.count)",
                            color: .yellow
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
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(dailySuccessRates, id: \.date) { data in
                                LineMark(
                                    x: .value("Date", data.date, unit: .day),
                                    y: .value("Success Rate", data.rate)
                                )
                                .foregroundStyle(.yellow)
                                .interpolationMethod(.catmullRom)
                                
                                PointMark(
                                    x: .value("Date", data.date, unit: .day),
                                    y: .value("Success Rate", data.rate)
                                )
                                .foregroundStyle(.yellow)
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
                                AxisGridLine()
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                AxisValueLabel(format: .dateTime.month().day())
                                AxisGridLine()
                            }
                        }
                        .frame(height: 250)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        )
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                
                // Recent History
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent History")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(routine.attempts.reversed().prefix(20)) { attempt in
                        HStack {
                            Image(systemName: attempt.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(attempt.isSuccess ? .yellow : .gray)
                            Text(attempt.isSuccess ? "Success" : "Miss")
                                .font(.subheadline)
                            Spacer()
                            Text(attempt.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
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
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title.bold())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
