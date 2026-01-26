# 🗓️ Year-Based Heatmap Update

## What Changed

The heatmap now displays data **per year** instead of showing a rolling 16-week window!

## New Behavior

### 🎯 Default View
- **Automatically shows current year** (2026)
- Displays from **January 1** to **today's date**
- Full year view (up to 52 weeks)

### 📅 Year Selection
- **Year dropdown** appears in top-right corner (if you have multi-year data)
- Shows available years in **reverse chronological order** (newest first)
- Click to switch between years
- Smooth animation when changing years

### 🔍 Year-Specific Display

#### Current Year (2026)
```
Jan 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━ Today
```
- Shows up to today
- Includes all weeks from January 1 to now

#### Past Years (2025, 2024, etc.)
```
Jan 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━ Dec 31
```
- Shows full year (all 12 months)
- January 1 through December 31

## UI Components

### Year Selector Button
```
┌─────────┐
│ 2026 ▼  │  ← Click to open dropdown
└─────────┘
```
- Only appears if you have data from multiple years
- Blue background matching app theme
- Monospaced font for clean look
- Checkmark shows current selection

### Dropdown Menu
```
┌─────────────┐
│ 2026 ✓      │  ← Current selection
│ 2025        │
│ 2024        │
└─────────────┘
```

## Benefits

### ✅ Clean Organization
- No cross-year data mixing
- Clear separation by calendar year
- Easy to compare year-over-year progress

### ✅ Better Context
- See your practice patterns for entire year
- Identify seasonal trends
- Compare different years side-by-side

### ✅ Faster Performance
- Only loads one year at a time
- Less data to render
- Smoother scrolling

### ✅ More Intuitive
- Matches how we think about time (by year)
- Natural year boundaries
- Familiar calendar structure

## Code Architecture

### Available Years Calculation
```swift
private var availableYears: [Int] {
    let years = practiceDates.map { calendar.component(.year, from: $0) }
    return Array(Set(years)).sorted(by: >) // Most recent first
}
```
- Extracts unique years from practice dates
- Sorts newest to oldest
- Updates automatically as you add data

### Date Range Logic
```swift
// Current year: Jan 1 to today
if selectedYear == currentYear {
    endDate = calendar.startOfDay(for: today)
}
// Past years: Jan 1 to Dec 31
else {
    endDate = Dec 31 of selected year
}
```

### State Management
```swift
@State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
```
- Initializes to current year
- Persists during session
- Updates with animation

## Example Scenarios

### Scenario 1: New User (Only 2026 data)
- ✅ No year selector shown (only one year)
- ✅ Shows current year by default
- ✅ Clean, simple interface

### Scenario 2: Multi-Year User (2024, 2025, 2026)
- ✅ Year selector appears
- ✅ Defaults to 2026
- ✅ Can tap to view 2025 or 2024
- ✅ Each year shows full calendar

### Scenario 3: Mid-Year View (June 2026)
- ✅ Shows Jan 1 - June 24
- ✅ Heatmap grows as year progresses
- ✅ Empty future dates not shown

### Scenario 4: Past Year View (2025)
- ✅ Shows complete year Jan-Dec
- ✅ All 52 weeks visible
- ✅ Historical record preserved

## Visual Comparison

### Before (Rolling 16 Weeks)
```
❌ Dec 2025  Jan 2026
   ■■■■■■   ■■■■■■■■■■
   (Mixed years, confusing)
```

### After (Year-Based)
```
✅ 2026 Only
   Jan  Feb  Mar  Apr  May  Jun
   ■■■■ ■■■■ ■■■■ ■■■■ ■■■■ ■■
   (Clear, organized)
```

## Stats Accuracy

The stats shown at top remain **lifetime totals**:
- "15 days practiced" = across all time
- "287 total attempts" = across all time
- Streak counter = current streak (regardless of year)

The **heatmap visual** shows only the selected year, but the overall stats reflect all your data!

## User Experience Flow

1. **Open Analytics tab**
2. **See current year (2026)** by default
3. **Notice year selector** (if multi-year data exists)
4. **Tap year selector** to see dropdown
5. **Select 2025** to view last year
6. **Heatmap animates** to show 2025 data
7. **Tap 2026** to return to current year

Smooth, intuitive, organized! 📊✨

## Technical Details

### Animation
- Uses `withAnimation` for smooth year transitions
- Spring animation matches cell interactions
- Consistent with app's design language

### Edge Cases Handled
- ✅ Leap years (366 days)
- ✅ Week alignment (starting Sunday)
- ✅ Partial years (current year)
- ✅ Empty years (no data)
- ✅ Single year (no dropdown)

### Performance
- Only renders selected year
- Computed properties update efficiently
- No unnecessary re-renders

## Future Enhancements

Ideas for later:
- Year comparison view (side-by-side)
- "Jump to today" button
- Year-over-year growth percentage
- Decade view for long-term users
- Export year as image

Perfect for tracking your martial arts journey year by year! 🥋📅
