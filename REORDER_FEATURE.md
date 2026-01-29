# Reorder Feature Implementation

## Overview
Added the ability to rearrange the order of combos/routines on the training page so users can practice their preferred moves first without having to scroll.

## Changes Made

### 1. Routine.swift
- Added `order: Int` property to track custom ordering
- Updated initializer to include the order parameter with default value of 0

### 2. RoutineStore.swift
- Modified `addRoutine()` to automatically assign order based on existing routines
- Added `reorderRoutines(from:to:in:)` method to handle reordering within a discipline
  - Takes source index, destination index, and discipline name
  - Updates the order property for all affected routines
  - Automatically saves changes via the `routines` didSet observer

### 3. ContentView.swift (DailyDrillView)
- Added `@State private var editMode: EditMode = .inactive` to track edit state
- Added `sortedRoutines(for:)` helper method to sort routines by custom order
- Added "Reorder" button in the header that toggles edit mode
  - Shows as "Done" when in edit mode (green)
  - Shows as "Reorder" in normal mode (blue)
- Replaced `ScrollView` + `LazyVStack` with `List` for native reorder support
- When in edit mode:
  - Shows simplified routine cards with drag handles
  - Enables `.onMove()` gesture for drag-and-drop reordering
  - Shows delete buttons via swipe actions (`.onDelete()`)
  - Hides success/miss buttons to avoid accidental taps
- When in normal mode:
  - Shows full `RoutineRowView` with all functionality
  - Context menu for deletion remains available

## User Experience

### How to Use:
1. Tap the "Reorder" button in the top-right corner of the Training tab
2. Drag the handle (three horizontal lines) on any routine to reorder it
3. The order is saved automatically as you drag
4. Tap "Done" to return to normal training mode
5. Your custom order persists across app launches

### Benefits:
- Practice your favorite combos first
- No more scrolling to find the move you want
- Order is maintained separately per discipline
- Visual feedback with simplified cards during reordering
- Intuitive iOS-native drag-and-drop interaction

## Technical Notes
- The `order` property is persisted via Codable/UserDefaults
- Reordering only affects routines within the same discipline
- The List approach provides native iOS reordering animations
- Edit mode prevents accidental button taps during reordering
