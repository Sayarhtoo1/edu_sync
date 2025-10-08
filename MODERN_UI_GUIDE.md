# Modern UI/UX Design Guide for EduSync

## Design System

### Colors
- **Primary Blue**: `#1E88E5` - Admin, General actions
- **Green**: `#4CAF50` - Teacher, Success states
- **Purple**: `#9C27B0` - Parent
- **Orange**: `#FF9800` - Donator, Warnings
- **Red**: `#F44336` - Errors, Delete actions
- **Background**: `#F5F7FA`
- **Card**: `#FFFFFF`
- **Text Dark**: `#2C2C2C`
- **Text Light**: `#757575`

### Typography
- **Heading**: 20-24px, Bold (FontWeight.bold)
- **Subheading**: 16-18px, SemiBold (FontWeight.w600)
- **Body**: 14-15px, Medium (FontWeight.w500)
- **Caption**: 12-13px, Regular (FontWeight.w400)

### Spacing
- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **XLarge**: 32px

### Border Radius
- **Cards**: 12px
- **Buttons**: 12px
- **Input Fields**: 12px
- **Large Cards**: 16px

### Shadows
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 4,
  offset: const Offset(0, 2),
)
```

## Component Patterns

### AppBar
```dart
AppBar(
  elevation: 0,
  backgroundColor: Colors.white,
  title: Text(title, style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
  iconTheme: IconThemeData(color: Color(0xFF2C2C2C)),
)
```

### Card
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
  ),
  child: child,
)
```

### Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF1E88E5),
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  ),
  child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
)
```

### List Item
```dart
Container(
  margin: EdgeInsets.only(bottom: 12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
  ),
  child: ListTile(
    contentPadding: EdgeInsets.all(16),
    leading: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    ),
    title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(subtitle),
  ),
)
```

### Input Field
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.grey[50],
  ),
)
```

### FAB
```dart
FloatingActionButton(
  backgroundColor: Color(0xFF1E88E5),
  child: Icon(Icons.add_rounded),
  onPressed: onPressed,
)
```

## Screen Structure

### Standard Screen Layout
```dart
Scaffold(
  backgroundColor: Color(0xFFF5F7FA),
  appBar: ModernAppBar(title: 'Screen Title'),
  body: RefreshIndicator(
    onRefresh: _loadData,
    child: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content here
        ],
      ),
    ),
  ),
  floatingActionButton: FloatingActionButton(...),
)
```

### List Screen Pattern
- Background: `#F5F7FA`
- Cards with 12px bottom margin
- White cards with subtle shadow
- Icon containers with colored backgrounds
- Pull-to-refresh enabled

### Form Screen Pattern
- White background or light gray
- Grouped sections with headers
- Rounded input fields
- Bottom action buttons
- Validation feedback

### Dashboard Pattern
- Gradient welcome card at top
- Metric cards in grid (2 columns)
- Quick action cards
- Recent activity list

## Animation Guidelines
- Fade in: 800ms with easeIn curve
- Card tap: Scale 0.95 with 100ms duration
- Page transitions: Default Flutter transitions
- Loading states: CircularProgressIndicator with brand color

## Accessibility
- Minimum touch target: 48x48px
- Color contrast ratio: 4.5:1 for text
- Semantic labels for icons
- Support for screen readers

## Implementation Checklist
For each screen:
- [ ] Use `Color(0xFFF5F7FA)` background
- [ ] White AppBar with dark text
- [ ] Cards with 12px radius and subtle shadow
- [ ] Consistent padding (16px)
- [ ] Icon containers with colored backgrounds
- [ ] Modern typography (bold headings, medium body)
- [ ] Rounded buttons with no elevation
- [ ] Pull-to-refresh where applicable
- [ ] Loading states
- [ ] Empty states with icons and messages
- [ ] Error handling with user-friendly messages
