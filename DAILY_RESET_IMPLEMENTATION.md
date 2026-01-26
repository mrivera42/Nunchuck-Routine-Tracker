# Daily Reset Implementation

## Overview
The training page now resets every day to show a clean slate, while all historical data is preserved for the Analytics section.

## How It Works

### 1. **Daily Tracking** (`RoutineStore.swift`)
- Added `lastResetDate` property that tracks when the daily view was last reset
- Automatically saves and loads this date from `UserDefaults`
- Added `checkAndResetIfNeeded()` method that compares current date with last reset date

### 2. **Today's Data Filtering** (`RoutineStore.swift`)
New helper methods were added to filter attempts:
- `todaysAttempts(for:)` - Returns only attempts from today
- `todaysSuccessCount(for:)` - Counts today's successes
- `todaysMissCount(for:)` - Counts today's misses  
- `todaysAccuracy(for:)` - Calculates today's accuracy percentage

### 3. **Training Page Display** (`RoutineRowView.swift`)
- Modified to accept `todaysAttempts` parameter
- Success/miss counts now show only today's data
- Visual history bar shows only today's attempts
- Resets to "READY TO ROLL" state each day

### 4. **Daily Reset Triggers** (`ContentView.swift`)
The app checks for daily reset in two scenarios:
- **When view appears**: `onAppear` in `DailyDrillView`
- **When app becomes active**: `onChange(of: scenePhase)` in `ContentView`

This ensures the view resets even if:
- User navigates between tabs
- App is left open overnight
- App returns from background

### 5. **Analytics Unchanged**
The Analytics section continues to use ALL historical data:
- Charts show progress over time
- Stats show lifetime totals
- No data is deleted, only filtered for display on training page

## Key Benefits

✅ **Clean slate each day** - Training page resets at midnight
✅ **Data preservation** - All historical attempts remain in storage
✅ **Automatic detection** - No manual reset needed
✅ **Real-time accuracy** - View updates when app becomes active
✅ **Analytics intact** - Historical analysis uses complete dataset

## Technical Details

### Data Storage
- All attempts remain in the `Routine.attempts` array with timestamps
- Only the **display** is filtered, not the underlying data
- `lastResetDate` is persisted in `UserDefaults` for reliability

### Date Comparison
```swift
let today = calendar.startOfDay(for: Date())
let lastReset = calendar.startOfDay(for: lastResetDate)

if today > lastReset {
    lastResetDate = today // New day detected
}
```

### Filtering Logic
```swift
return routine.attempts.filter { attempt in
    calendar.isDate(attempt.date, inSameDayAs: today)
}
```

This ensures only attempts from the current calendar day are shown in training view.
