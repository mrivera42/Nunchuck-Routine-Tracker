# 🎨 GitHub-Style Heatmap - Visual Guide

## What You'll See

### Main Heatmap View

```
Practice Activity                         🔥 5
15 days • 287 total attempts

    Oct      Nov      Dec      Jan
    
S   □ □ □ ■ □ □ ■ ■ □ ■ ■ ■ □ ■ ■ ■
M   ■ ■ □ ■ ■ □ ■ ■ ■ ■ ■ □ ■ ■ ■ ■
    □ ■ ■ ■ □ ■ □ ■ ■ ■ ■ ■ ■ ■ □ ■
W   ■ □ ■ ■ ■ ■ ■ □ ■ ■ ■ ■ □ ■ ■ [■] ← Today (glowing)
    ■ ■ ■ □ ■ ■ □ ■ ■ □ ■ ■ ■ ■ ■ ■
F   □ ■ ■ ■ ■ ■ ■ ■ □ ■ ■ □ ■ ■ ■ ■
    ■ ■ □ ■ ■ □ ■ ■ ■ ■ □ ■ ■ □ ■ ■

Less ▢ ▢ ▢ ▢ ▢ More
```

### Color Intensity Legend

```
▢ Empty (Gray opacity 0.1)      - No practice
▢ Level 1 (Blue opacity 0.3)    - 1-5 attempts
▢ Level 2 (Blue opacity 0.5)    - 6-15 attempts  
▢ Level 3 (Blue opacity 0.7)    - 16-30 attempts
▢ Level 4 (Blue solid)          - 31+ attempts
```

### Interactive Elements

#### 1. Tap a Cell → Detail Sheet Appears

```
╔════════════════════════════════╗
║  Jan 22, 2026                ✕ ║
║  Wednesday                     ║
║                                ║
║  ┌──────────────────────────┐ ║
║  │  🥋    24                 │ ║
║  │       attempts            │ ║
║  │  ─────────────────        │ ║
║  │  Heavy practice           │ ║
║  └──────────────────────────┘ ║
╚════════════════════════════════╝
```

#### 2. Streak Counter (Top Right)

```
┌──────────┐
│  🔥 5    │  ← Current streak
└──────────┘
(Orange badge, only shows if streak > 0)
```

#### 3. Cell Interaction

- **Normal state**: Regular size, standard color
- **Tapped/Long press**: Scales to 1.2x with spring animation
- **Today**: Blue border + subtle blue glow
- **Empty day**: Light gray, slightly transparent

### Layout Breakdown

```
┌─────────────────────────────────────────┐
│ Practice Activity              🔥 5     │ ← Header with stats
│ 15 days • 287 total attempts            │
│                                         │
│     Oct    Nov    Dec    Jan            │ ← Month labels
│                                         │
│  S  □ □ □ ■ □ □ ■ ...                  │ ← Grid with day labels
│  M  ■ ■ □ ■ ■ □ ■ ...                  │
│     □ ■ ■ ■ □ ■ □ ...                  │
│  W  ■ □ ■ ■ ■ ■ ■ ...                  │
│     ■ ■ ■ □ ■ ■ □ ...                  │
│  F  □ ■ ■ ■ ■ ■ ■ ...   < Scrollable   │
│     ■ ■ □ ■ ■ □ ■ ...                  │
│                                         │
│  Less ▢ ▢ ▢ ▢ ▢ More                   │ ← Legend
└─────────────────────────────────────────┘
```

## Animation Behaviors

### 1. Spring Animation on Tap
```
Normal (1.0x) → [Tap] → Large (1.2x) → Release → Normal (1.0x)
```
- Response: 0.3 seconds
- Damping: 0.6 (slightly bouncy)

### 2. Today Glow Effect
```
[■] ← Pulsing blue glow
    (Shadow radius 4, opacity 0.4)
```

### 3. Sheet Presentation
```
Bottom → Slides up → Stops at 250pt height
```

## Intensity Descriptions

The detail sheet shows different messages based on attempts:

| Attempts | Description | Color |
|----------|-------------|-------|
| 0 | "No activity" | Gray |
| 1-5 | "Light practice" | Light Blue |
| 6-15 | "Moderate practice" | Medium Blue |
| 16-30 | "Heavy practice" | Dark Blue |
| 31+ | "Intense training! 🔥" | Orange |

## Size Reference

```
Cell: 14 x 14 points
Spacing: 3 points between cells
Corner radius: 2 points
Today border: 1.5 points

Week width: 14pt (cell) = 14pt
Full week height: (14 × 7) + (3 × 6) = 116pt

Header: ~60pt
Month labels: ~20pt
Day labels: Width 25pt
Legend: ~30pt
```

## Scrolling Behavior

```
← Scroll Left (Past)              Scroll Right (Recent) →

Week 1   Week 2   Week 3   Week 4   ...   Week 15   Week 16 (Current)
  ↑                                                      ↑
4 months ago                                          Now
```

- Shows 16 weeks (about 4 months) of history
- Horizontal scroll enabled
- Start position: Shows most recent weeks
- Smooth scrolling with indicators hidden

## Touch Targets

```
Active area per cell: 14pt × 14pt (minimum)
Recommended: 44pt × 44pt (handled by tap gesture extension)
```

## Accessibility Considerations

For future enhancement:
- VoiceOver labels: "January 22, 24 attempts, Heavy practice"
- Dynamic Type support for labels
- High contrast mode: Stronger color differences
- Reduce motion: Disable spring animations

## Color Specifications

```swift
// Empty
Color.gray.opacity(0.1)

// Level 1 (Light)
Color.blue.opacity(0.3)

// Level 2 (Moderate)
Color.blue.opacity(0.5)

// Level 3 (Heavy)
Color.blue.opacity(0.7)

// Level 4 (Intense)
Color.blue (full opacity)

// Today indicator
Border: Color.blue
Shadow: Color.blue.opacity(0.4), radius: 4

// Streak badge
Background: Color.orange.opacity(0.15)
Text: Color.orange
```

## Typography

```
Header title: .headline, monospaced, bold, blue
Stats text: 10pt, monospaced, medium, gray
Month labels: 9pt, monospaced, medium, gray
Day labels: 9pt, monospaced, medium, gray
Legend: 9pt, monospaced, medium, gray
Streak: 12pt, monospaced, bold, orange

Detail sheet title: .title2, monospaced, bold, blue
Detail sheet subtitle: .subheadline, monospaced, gray
Attempt count: 40pt, monospaced, bold, blue
Intensity: .subheadline, monospaced, medium, dynamic color
```

## Visual Hierarchy

```
1. TODAY'S CELL (Brightest, glowing, outlined)
2. Streak Badge (Orange, top-right)
3. High-intensity cells (Darkest blue)
4. Medium-intensity cells
5. Low-intensity cells  
6. Empty cells (Faintest)
```

This creates a natural focus on:
- Current progress (today)
- Consistency (streak)
- Intensity (darker = more practice)

Perfect for quick glances and motivation! 🚀
