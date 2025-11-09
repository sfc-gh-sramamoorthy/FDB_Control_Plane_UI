# UI Layout Reference

## Visual Overview

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃                              EFDB UI                                        ┃
┣━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                      ┃                                                      ┃
┃  Object Identifier   ┃              Object Information                      ┃
┃                      ┃                                                      ┃
┃  Input 1:            ┃  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  ┃
┃  [______________]    ┃  ┃  Identifier: value1 • value2                  ┃  ┃
┃                      ┃  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  ┃
┃  Input 2:            ┃                                                      ┃
┃  [______________]    ┃  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  ┃
┃                      ┃  ┃  Status                                       ┃  ┃
┃  ─────────────────   ┃  ┃  Active                                       ┃  ┃
┃                      ┃  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  ┃
┃  Refresh Settings    ┃                                                      ┃
┃                      ┃  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  ┃
┃  Refresh Interval:   ┃  ┃  Type                                         ┃  ┃
┃  [____30_______]     ┃  ┃  Sample Object                                ┃  ┃
┃                      ┃  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  ┃
┃  Auto Refresh [⚪]   ┃                                                      ┃
┃                      ┃  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  ┃
┃  ─────────────────   ┃  ┃  Description                                  ┃  ┃
┃                      ┃  ┃  Additional information...                    ┃  ┃
┃  [  Refresh Now  ]   ┃  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  ┃
┃                      ┃                                                      ┃
┃  [     Clear     ]   ┃  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  ┃
┃                      ┃  ┃  Timestamp                                    ┃  ┃
┃                      ┃  ┃  2025-11-09T08:23:45Z                         ┃  ┃
┃                      ┃  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  ┃
┃  ⏳ Loading...       ┃                                                      ┃
┃  Last update: 8:23   ┃                                                      ┃
┃                      ┃                                                      ┃
┗━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

## Layout Details

### Left Panel - Input & Controls (250-300px width)

1. **Object Identifier Section**
   - Two text input fields
   - Labels with light gray captions
   - Rounded border style

2. **Refresh Settings Section**
   - Numeric input for refresh interval
   - Toggle switch for auto-refresh
   - Clear visual separation with dividers

3. **Action Buttons**
   - "Refresh Now" - Primary button (blue)
   - "Clear" - Secondary button (gray)
   - Full-width layout

4. **Status Area**
   - Loading indicator when fetching data
   - Last update timestamp
   - Small, non-intrusive font

### Right Panel - Information Display (Flexible width)

1. **Header Section**
   - Large title "Object Information"
   - Subtitle showing current identifier values
   - System icons for visual clarity

2. **Information Cards**
   - Each piece of info in a separate card
   - Card structure:
     - Bold title/label
     - Value in a light background box
     - Subtle border and shadow
   - Cards are scrollable

3. **Empty State** (when no data)
   - Centered icon (tray)
   - "No data loaded" message
   - Helpful instruction text

## Color Scheme

### Light Mode (Default)
- Background: System background color
- Cards: White with subtle gray border
- Text: System primary text color
- Input fields: White with border
- Buttons: System blue for primary, gray for secondary

### Dark Mode (Automatic)
- Background: System dark background
- Cards: Dark gray with subtle border
- Text: White/light gray
- Input fields: Dark with subtle border
- Buttons: System blue for primary, gray for secondary

## Component Hierarchy

```
WindowGroup
└── NavigationSplitView
    ├── Sidebar (InputPanel)
    │   ├── VStack
    │   │   ├── Text ("Object Identifier")
    │   │   ├── Input Fields (VStack)
    │   │   │   ├── TextField (Input 1)
    │   │   │   └── TextField (Input 2)
    │   │   ├── Divider
    │   │   ├── Refresh Settings (VStack)
    │   │   │   ├── TextField (Interval)
    │   │   │   └── Toggle (Auto Refresh)
    │   │   ├── Divider
    │   │   ├── Action Buttons (VStack)
    │   │   │   ├── Button (Refresh Now)
    │   │   │   └── Button (Clear)
    │   │   └── Status (VStack)
    │   │       ├── ProgressView
    │   │       └── Text (Last Update)
    │   └── Spacer
    └── Detail (DetailPanel)
        ├── Empty State (VStack)
        │   ├── Image (tray icon)
        │   ├── Text ("No data loaded")
        │   └── Text (instruction)
        └── ScrollView (when data present)
            └── VStack
                ├── Header (VStack)
                │   ├── Text (Title)
                │   └── HStack (Identifiers)
                ├── Divider
                └── ForEach (InfoCard)
                    ├── Text (Title)
                    └── Text (Value in box)
```

## Responsive Behavior

### Window Sizing
- **Minimum Width**: 650px (prevents squishing)
- **Minimum Height**: 400px
- **Default Size**: 900x600
- **Maximum**: No limit (grows with content)

### Panel Behavior
- **Left Panel**: Fixed width (250-300px)
- **Right Panel**: Takes remaining space
- **Divider**: Can be dragged to resize panels

### Content Behavior
- **Long text**: Wraps within cards
- **Many cards**: Scrollable vertically
- **No data**: Centered empty state

## Interaction Patterns

### Input Changes
1. User types in input fields
2. No automatic refresh (user controls when to fetch)
3. Must click "Refresh Now" to fetch data

### Refresh Flow
1. User clicks "Refresh Now" or auto-refresh triggers
2. Loading indicator appears in left panel
3. Right panel shows loading state (or keeps old data)
4. Data fetches asynchronously
5. Right panel updates with new info
6. Last update timestamp updates

### Auto-Refresh
1. User toggles "Auto Refresh" ON
2. Timer starts based on interval
3. Every N seconds, data refreshes automatically
4. User can toggle OFF to stop

### Clear Action
1. User clicks "Clear"
2. All info cards are removed
3. Empty state is shown
4. Input fields remain unchanged
5. Last update timestamp cleared

## Accessibility

- All inputs have descriptive labels
- Proper focus order (top to bottom, left to right)
- Keyboard navigation supported
- VoiceOver compatible
- High contrast mode supported
- Dynamic type supported

## Future Enhancements

Potential UI additions:
- [ ] Search/filter in info cards
- [ ] Export data button
- [ ] History/recent queries
- [ ] Multiple tabs for different objects
- [ ] Dark mode toggle (manual override)
- [ ] Customizable themes
- [ ] Resizable font size
- [ ] Pin favorite configurations
- [ ] Notifications for changes
- [ ] Graphs/charts for numeric data

## Customization Points

### Easy Changes
1. **Colors**: Modify in `ContentView.swift`
   - `.foregroundColor()` for text
   - `.background()` for backgrounds
   - `.accentColor()` for highlights

2. **Spacing**: Adjust in VStack/HStack
   - `spacing:` parameter
   - `.padding()` modifiers

3. **Sizes**: Modify in frame()
   - `.frame(width:, height:)`
   - `.minWidth()`, `.maxWidth()`

4. **Fonts**: Change text styles
   - `.font(.headline)`, `.font(.body)`, etc.

### Advanced Changes
1. **Layout**: Switch from NavigationSplitView to HSplitView
2. **Panels**: Add third panel for additional info
3. **Animations**: Add transitions and animations
4. **Custom Components**: Create new card types

---

See `ContentView.swift` for the actual implementation.

