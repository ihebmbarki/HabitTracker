//
//  HabitTrackerTests.swift
//  HabitTrackerTests
//
//  Created by Iheb Mbarki on 17/9/2024.
//

import XCTest
@testable import HabitTracker

class HabitTrackerTests: XCTestCase {

    var habitViewModel: HabitViewModel!

    override func setUp() {
        super.setUp()
        habitViewModel = HabitViewModel()
    }

    override func tearDown() {
        habitViewModel = nil
        super.tearDown()
    }
    
    // Test habit creation
    func testAddNewHabit() {
        // Given
        let initialHabitCount = habitViewModel.habits.count
        let newHabitTitle = "Test Habit"
        let newHabitCategory = "Test Category"
        let newHabitFrequency = "Daily"
        let newHabitDescription = "This is a test habit"
        
        // When
        habitViewModel.habits.append(Habit(title: newHabitTitle, category: newHabitCategory, frequency: newHabitFrequency, description: newHabitDescription))
        
        // Then
        XCTAssertEqual(habitViewModel.habits.count, initialHabitCount + 1, "Habit count should increase by 1")
        XCTAssertEqual(habitViewModel.habits.last?.title, newHabitTitle, "The last habit added should match the new habit title")
        XCTAssertEqual(habitViewModel.habits.last?.category, newHabitCategory, "The category should match the provided category")
    }
    
    // Test marking a habit as done
    func testMarkHabitAsDone() {
        // Given
        let habit = Habit(title: "Test Habit", category: "Test Category", frequency: "Daily")
        habitViewModel.habits.append(habit)
        let initialStreak = habit.streak
        
        // When
        habitViewModel.markHabitAsDone(habit: habit)
        
        // Then
        XCTAssertEqual(habitViewModel.habits[0].streak, initialStreak + 1, "Streak should increase by 1 when a habit is marked as done")
        XCTAssertEqual(habitViewModel.habits[0].completedDates.count, 1, "There should be one completed date")
    }
    
    // Test completion rate calculation
    func testCompletionRate() {
        // Given
        let habit = Habit(title: "Test Habit", category: "Test Category", frequency: "Daily", goal: 5)
        habitViewModel.habits.append(habit)
        
        // Mark the habit as done twice
        habitViewModel.markHabitAsDone(habit: habit)
        habitViewModel.markHabitAsDone(habit: habit)
        
        // When
        let completionRate = habitViewModel.completionRate(habit: habit)
        
        // Then
        XCTAssertEqual(completionRate, 2.0 / 5.0, "The completion rate should be 2/5")
    }
    
    // Test if habit is done for a specific day
    func testIsHabitDoneForDate() {
        // Given
        let habit = Habit(title: "Test Habit", category: "Test Category", frequency: "Daily")
        habitViewModel.habits.append(habit)
        let today = Calendar.current.startOfDay(for: Date())
        
        // When
        habitViewModel.markHabitAsDone(habit: habit)
        let isDone = habitViewModel.isHabitDone(for: habit, on: today)
        
        // Then
        XCTAssertTrue(isDone, "Habit should be marked as done for today")
    }
}
