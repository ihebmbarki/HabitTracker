//
//  ContentView.swift
//  HabitTracker
//
//  Created by Iheb Mbarki on 17/9/2024.
//

import SwiftUI

struct Habit: Identifiable {
    var id = UUID()
    var title: String
    var category: String
    var frequency: String
    var description: String?
    var goal: Int? // Optional goal
    var streak: Int = 0
    var completedDates: [Date] = [] // History of completed dates
}

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = [
        Habit(title: "Drink Water", category: "Health", frequency: "Daily", description: "Drink 8 glasses", goal: 30),
        Habit(title: "Exercise", category: "Fitness", frequency: "Weekly", description: "Workout 3 times a week", goal: 20),
        Habit(title: "Read a Book", category: "Learning", frequency: "Daily", description: "Read for 30 minutes", goal: 10)
    ]
    
    func markHabitAsDone(habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            let today = Calendar.current.startOfDay(for: Date())
            if !habits[index].completedDates.contains(today) {
                habits[index].completedDates.append(today)
                habits[index].streak += 1
            }
        }
    }
    
    func completionRate(habit: Habit) -> Double {
        guard let goal = habit.goal else { return 0.0 }
        return Double(habit.completedDates.count) / Double(goal)
    }
    
    func isHabitDone(for habit: Habit, on date: Date) -> Bool {
        let day = Calendar.current.startOfDay(for: date)
        return habit.completedDates.contains(day)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = HabitViewModel()
    @State private var showingAddHabitSheet = false
    @State private var selectedTimeFrame: String = "Daily"
    
    let timeFrames = ["Daily", "Weekly", "Monthly"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Time frame picker (Daily, Weekly, Monthly)
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(timeFrames, id: \.self) { frame in
                        Text(frame)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // List of habits with progress visualization
                List {
                    ForEach(viewModel.habits) { habit in
                        VStack(alignment: .leading) {
                            Text(habit.title)
                                .font(.headline)
                            Text("Category: \(habit.category)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Frequency: \(habit.frequency)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            // Streak Progress Bar
                            Text("Current Streak: \(habit.streak) days")
                            ProgressView(value: Double(habit.streak), total: Double(habit.goal ?? 100))
                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            
                            // Habit completion rate bar
                            if let goal = habit.goal {
                                Text("Completion Rate: \(Int(viewModel.completionRate(habit: habit) * 100))%")
                                ProgressView(value: viewModel.completionRate(habit: habit))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            }
                            
                            // Checkmark progress view
                            CheckmarkProgressView(habit: habit, selectedTimeFrame: selectedTimeFrame, viewModel: viewModel)
                            
                            if let description = habit.description {
                                Text("Description: \(description)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            if let goal = habit.goal {
                                Text("Goal: \(goal) days")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            // Button to mark as done
                            HStack {
                                Spacer()
                                Button(action: {
                                    viewModel.markHabitAsDone(habit: habit)
                                }) {
                                    Text("Mark as Done")
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .navigationTitle("Habit Tracker")
                .toolbar {
                    // Add button to show habit creation sheet
                    Button(action: {
                        showingAddHabitSheet = true
                    }) {
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .sheet(isPresented: $showingAddHabitSheet) {
                    AddHabitView(viewModel: viewModel)
                }
            }
        }
    }
}

// MARK: - Custom Date Generation for Time Frames
extension Calendar {
    func generateDates(interval: DateInterval, byAdding component: Calendar.Component, value: Int) -> [Date] {
        var dates: [Date] = []
        var currentDate = interval.start
        
        while currentDate <= interval.end {
            dates.append(currentDate)
            currentDate = date(byAdding: component, value: value, to: currentDate)!
        }
        
        return dates
    }
}

// MARK: - Checkmark Progress View
struct CheckmarkProgressView: View {
    var habit: Habit
    var selectedTimeFrame: String
    var viewModel: HabitViewModel
    
    // Generate dates for the selected time frame (Daily, Weekly, Monthly)
    private var daysInTimeFrame: [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        switch selectedTimeFrame {
        case "Weekly":
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
        case "Monthly":
            let monthInterval = calendar.dateInterval(of: .month, for: today)!
            return calendar.generateDates(interval: monthInterval, byAdding: .day, value: 1)
        default:  // Daily
            return [today]
        }
    }
    
    var body: some View {
        HStack {
            ForEach(daysInTimeFrame, id: \.self) { day in
                Image(systemName: viewModel.isHabitDone(for: habit, on: day) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(viewModel.isHabitDone(for: habit, on: day) ? .green : .gray)
                    .font(.title2)
                    .padding(4)
            }
        }
    }
}

// MARK: - Add Habit View
struct AddHabitView: View {
    @ObservedObject var viewModel: HabitViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var category = ""
    @State private var frequency = ""
    @State private var description = ""
    @State private var goal = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Details")) {
                    TextField("Habit Title", text: $title)
                    TextField("Category", text: $category)
                    TextField("Frequency", text: $frequency)
                    TextField("Goal (optional)", text: $goal)
                        .keyboardType(.numberPad)
                    TextField("Description (optional)", text: $description)
                }
            }
            .navigationBarTitle("Add New Habit", displayMode: .inline)
            .navigationBarItems(trailing: Button("Save") {
                guard !title.isEmpty, !category.isEmpty, !frequency.isEmpty else { return }
                let goalInt = Int(goal) ?? 0
                viewModel.habits.append(Habit(title: title, category: category, frequency: frequency, description: description.isEmpty ? nil : description, goal: goalInt > 0 ? goalInt : nil))
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

import SwiftUI

@main
struct HabitTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
