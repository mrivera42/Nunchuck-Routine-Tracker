# ⭐ Daily Goals & Achievement Badges

## Overview
Added goal setting and achievement badges to make training more motivating! Now you can set daily success targets for each routine and earn visual rewards when you hit them.

## New Features

### 🎯 Daily Goals
Set a target number of successes for each routine:
- **Customizable per routine** - Different goals for different moves
- **Flexible** - Easy to change or remove anytime
- **Persistent** - Goals save with your data

### ⭐ Achievement Badges
Visual celebration when you hit your goal:
- **Gold star badge** - "GOAL" badge appears on routine card
- **Yellow highlight** - Hard to miss!
- **Progress tracker** - See "5/10 successes today" under routine name
- **Green text** - Progress turns green when goal is complete

### ✏️ Edit Button
Easy access to routine settings:
- **Pencil icon** - Top-right corner of each routine card
- **Quick tap** - Opens edit sheet
- **Clean design** - Subtle but accessible

## UI Components

### Routine Card with Goal Badge
```
┌───────────────────────────────────────┐
│ Basic Spin  [⭐ GOAL]            ✏️   │
│ 10/10 successes today    ✓5  ✗2  100%│
│ ━━━━━━━━━━━━━━━━━━━━━━━━             │
│ ✓ ✓ ✗ ✓ ✓ ✓ ✗ ✓ ✓ ✓                │
│ [Success]  [Miss]                     │
└───────────────────────────────────────┘
```

### Edit Sheet
```
┌─────────────────────────────────┐
│ Cancel     Edit Routine    Save │
├─────────────────────────────────┤
│ ROUTINE NAME                    │
│ Basic Spin                      │
│                                 │
│ DAILY GOAL                      │
│ Daily Goal          10 successes│
│ ⭐ You'll earn a goal badge     │
│    when you reach 10 successes  │
│ [Clear Goal]                    │
│                                 │
│ STATISTICS                      │
│ Total Attempts             156  │
│ Success Rate               87%  │
└─────────────────────────────────┘
```

## User Flow

### Setting a Goal
1. **Tap pencil icon** on any routine card
2. **Enter number** in "Daily Goal" field (e.g., 10)
3. **Tap Save**
4. Goal is now set!

### Tracking Progress
- Practice as normal
- **Progress shows** under routine name: "5/10 successes today"
- **Badge appears** when you hit the goal
- Resets daily (clean slate each day)

### Editing/Removing Goal
1. **Tap pencil icon** again
2. **Change number** or tap "Clear Goal"
3. **Save** to update

## Visual Design

### Goal Badge (When Achieved)
- **Background**: Yellow with 20% opacity
- **Border**: Yellow with 50% opacity, 1pt
- **Icon**: Star fill (yellow)
- **Text**: "GOAL" in bold monospaced font
- **Size**: Compact, fits inline with routine name

### Progress Indicator
- **Format**: "X/Y successes today"
- **Color**: Gray normally, green when complete
- **Font**: 11pt monospaced, medium weight
- **Position**: Below routine name

### Edit Button
- **Icon**: Pencil circle fill
- **Size**: 20pt
- **Color**: Blue with 60% opacity
- **Style**: Plain (no button background)
- **Position**: Top-right, before stats

## Code Architecture

### Model Changes (`Routine.swift`)
```swift
struct Routine {
    ...
    var dailyGoal: Int? // nil = no goal
}
```

### Store Updates (`RoutineStore.swift`)
```swift
func updateRoutine(_ routine: Routine) {
    // Updates routine in array and saves
}
```

### View Updates (`RoutineRowView.swift`)
```swift
- Added `onEdit` callback
- Added `goalCompleted` computed property
- Added goal badge UI
- Added progress text
- Added edit button
```

### New Component (`EditRoutineSheet`)
- NavigationStack with Form
- Name editing
- Goal setting with number pad
- Clear goal button
- Statistics display
- Save/Cancel actions

## Goal Logic

### Progress Calculation
```swift
private var goalCompleted: Bool {
    guard let goal = routine.dailyGoal else { return false }
    return successCount >= goal
}
```
- Uses today's success count only
- Compares to goal (if set)
- Returns true when goal reached or exceeded

### Daily Reset
- Goals are **persistent** (don't reset)
- **Progress resets daily** (uses `todaysAttempts`)
- Can hit goal again each day
- Badge only shows when today's count meets goal

## Benefits

### 💪 Motivation
- Clear targets to hit
- Visual reward when successful
- Gamification encourages practice

### 📊 Structure
- Organizes daily practice
- Prevents over/under training
- Balanced goals per routine

### 🎉 Satisfaction
- Immediate feedback
- Achievement recognition
- Progress tracking

### 🔄 Flexibility
- Easy to adjust goals
- Optional (can practice without goals)
- Per-routine customization

## Example Scenarios

### Scenario 1: New Routine
1. Add "Figure 8" routine
2. Tap edit, set goal: 15 successes
3. Practice and track progress
4. Hit 15 ✓ → Gold star appears! ⭐

### Scenario 2: Ambitious Goal
- Set goal: 50 successes
- Progress shows: "12/50 successes today"
- Visual feedback keeps you motivated
- Hit it eventually → Badge earned!

### Scenario 3: No Goal
- Leave goal field empty
- Routine works normally
- No badge, just regular tracking
- Add goal later if desired

### Scenario 4: Adjusting Goals
- Had goal of 20, too hard
- Edit and change to 10
- More achievable
- Hit goal more often = more motivation

## Technical Details

### State Management
```swift
@State private var showingEditRoutine = false
@State private var editingRoutine: Routine?
```
- Sheet presentation boolean
- Currently editing routine reference

### Goal Persistence
- Stored in `Routine` model
- Encoded/decoded with JSON
- Saved to UserDefaults
- Survives app restarts

### Progress Tracking
- Uses existing `todaysAttempts` filtering
- Counts successes only (not total attempts)
- Compares to goal threshold
- Updates in real-time as you practice

### UI Updates
- Badge shows/hides based on `goalCompleted`
- Progress text updates reactively
- Green color applied when goal met
- Smooth, no lag

## Accessibility

Current features:
- ✅ Large touch targets (edit button)
- ✅ Clear labels
- ✅ High contrast badge
- ✅ Monospaced fonts for readability

Future enhancements:
- VoiceOver labels for badge
- Dynamic Type support
- Haptic feedback on goal completion
- Celebration animation

## Future Ideas

### Enhanced Celebrations
- Confetti animation on goal completion
- Sound effect option
- Haptic feedback pattern
- Share achievement option

### Advanced Goals
- Weekly goals (not just daily)
- Accuracy goals (e.g., 90% success rate)
- Combo goals (multiple routines)
- Streak goals (X days in a row)

### Statistics
- Goal completion rate over time
- Average days to hit goal
- Hardest/easiest goals
- Goal achievement badges collection

### Gamification
- Points system
- Levels/ranks
- Leaderboards (if multi-user)
- Achievements library

## Summary

✅ **Set daily goals** - Target successes per routine
✅ **Track progress** - See X/Y under routine name
✅ **Earn badges** - Gold star when goal achieved
✅ **Easy editing** - Tap pencil to adjust anytime
✅ **Daily reset** - Fresh start each day
✅ **Flexible** - Optional, customizable, removable

Perfect for staying motivated and focused during training! 🥋⭐
