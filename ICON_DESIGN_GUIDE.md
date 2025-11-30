# App Icon Design Guide

## Overview
This guide provides specifications for creating the Meal Prep Vision Tracker app icon.

## Design Concept

### Theme
- **Primary**: Food + Technology fusion
- **Style**: Modern, minimalist, friendly
- **Colors**: Green (#34C759 systemGreen) with complementary colors
- **Imagery**: Camera + Food elements

### Icon Ideas

**Option 1: Camera + Vegetable**
- Camera lens with a carrot or broccoli emerging from it
- Gradient green background
- Clean, recognizable silhouettes

**Option 2: Fork + Camera**
- Fork and knife crossed with camera lens
- Circular badge design
- White icons on green gradient

**Option 3: Scanning Frame**
- Ingredient (apple/tomato) with scanning frame overlay
- Tech-meets-organic aesthetic
- Depth with subtle shadows

## Technical Specifications

### Required Sizes
Create icons at these exact pixel dimensions:

| Size | Purpose | Filename |
|------|---------|----------|
| 1024x1024 | App Store | AppIcon-1024.png |
| 180x180 | iPhone @3x | AppIcon-60@3x.png |
| 120x120 | iPhone @2x | AppIcon-60@2x.png |
| 167x167 | iPad Pro | AppIcon-83.5@2x.png |
| 152x152 | iPad @2x | AppIcon-76@2x.png |
| 76x76 | iPad | AppIcon-76.png |
| 120x120 | Spotlight @3x | AppIcon-40@3x.png |
| 80x80 | Spotlight @2x | AppIcon-40@2x.png |
| 40x40 | Spotlight | AppIcon-40.png |
| 87x87 | Settings @3x | AppIcon-29@3x.png |
| 58x58 | Settings @2x | AppIcon-29@2x.png |
| 29x29 | Settings | AppIcon-29.png |
| 60x60 | Notification @3x | AppIcon-20@3x.png |
| 40x40 | Notification @2x | AppIcon-20@2x.png |
| 20x20 | Notification | AppIcon-20.png |

### Design Guidelines

**DO:**
- Use simple, recognizable shapes
- Ensure clarity at small sizes (29x29)
- Use consistent color palette
- Keep design centered
- Test on actual devices
- Use high-contrast elements
- Export at exact pixel dimensions
- Use PNG format with no transparency

**DON'T:**
- Use transparency/alpha channels
- Add rounded corners (iOS does this)
- Include text (hard to read at small sizes)
- Use photos or complex gradients
- Include borders (iOS adds them)
- Use too many colors
- Make details too fine

### Color Palette

**Primary Green**
- Hex: #34C759
- RGB: 52, 199, 89
- Use: Main brand color

**Secondary Colors**
- Light Green: #8FD752
- Dark Green: #2A9D4A
- White: #FFFFFF (for contrast)
- Gray: #8E8E93 (for shadows)

### Typography
**Note**: Avoid text in icons, but if branding required:
- Font: SF Pro Rounded or similar
- Weight: Bold
- Max 2-3 letters

## Design Tools

### Recommended Software
1. **Figma** (Free, web-based)
   - Template: [Figma iOS Icon Template](https://www.figma.com)
   
2. **Sketch** (Mac only)
   - Plugin: Sketch App Icon Generator

3. **Adobe Illustrator**
   - Export: Asset Export feature

4. **Affinity Designer** (One-time purchase)
   - More affordable alternative

### Icon Generation Tools
- [App Icon Generator](https://appicon.co) - Upload 1024x1024, get all sizes
- [MakeAppIcon](https://makeappicon.com) - Free batch export
- [AppIconizer](https://appiconizer.com) - Drag and drop

## Creation Workflow

### Step 1: Concept Design (1024x1024)
1. Create artboard at 1024x1024px
2. Design icon with 96px padding (keep important elements in 832x832 safe area)
3. Use vector shapes for scalability
4. Test legibility at 29x29 preview size

### Step 2: Refinement
1. Check at multiple sizes
2. Ensure recognizability at small sizes
3. Test on light and dark backgrounds
4. Simplify if needed

### Step 3: Export All Sizes
1. Use icon generator tool or manual export
2. Verify each size looks sharp
3. Check file sizes (reasonable, not too large)
4. Name files exactly as specified

### Step 4: Implementation
1. Replace placeholder files in Assets.xcassets/AppIcon.appiconset/
2. Ensure Contents.json matches filenames
3. Build and test on device
4. Check Home Screen appearance
5. Verify Settings and Spotlight icons

## Testing Checklist

- [ ] Icon looks sharp at all sizes
- [ ] Recognizable at 29x29 (smallest size)
- [ ] Works on light background (Home Screen)
- [ ] Works on dark background (Dark Mode)
- [ ] No pixelation or artifacts
- [ ] Consistent with app branding
- [ ] Memorable and unique
- [ ] Passes App Store review guidelines

## Placeholder Icon

Until custom icons are created, you can use a temporary icon:

### Quick Placeholder Creation
```swift
// In Xcode, create a placeholder programmatically:
let size = CGSize(width: 1024, height: 1024)
let renderer = UIGraphicsImageRenderer(size: size)
let image = renderer.image { context in
    UIColor.systemGreen.setFill()
    context.fill(CGRect(origin: .zero, size: size))
    
    // Add camera glyph
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 512, weight: .light)
    if let symbol = UIImage(systemName: "camera.fill", withConfiguration: symbolConfig) {
        symbol.withTintColor(.white).draw(in: CGRect(x: 256, y: 256, width: 512, height: 512))
    }
}
```

## App Store Marketing

### Additional Marketing Assets Needed

**App Store Screenshots** (create after icon)
- Use icon colors in screenshot frames
- Consistent visual language
- Include icon in promo materials

**Feature Graphic** (if needed)
- 1024x500px horizontal banner
- Icon + tagline
- Use for websites/social media

## Resources

### Inspiration
- [Dribbble iOS Icons](https://dribbble.com/search/ios-app-icon)
- [Apple Design Resources](https://developer.apple.com/design/resources/)
- [SF Symbols App](https://developer.apple.com/sf-symbols/)

### Guidelines
- [Apple Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### Color Tools
- [Coolors.co](https://coolors.co) - Palette generator
- [ColorSpace](https://mycolor.space) - Gradient maker

## Example Brief for Designer

```
Project: Meal Prep Vision Tracker App Icon
Style: Modern, friendly, minimalist
Theme: Food + AI/Camera technology
Colors: Green (#34C759) primary, with complementary colors
Imagery: Camera/scanning + food/ingredient elements
Size: 1024x1024 master, need all iOS sizes
Format: PNG, no transparency
Deadline: [Your deadline]
Budget: [If hiring]
```

---

## Notes

- Current AppIcon.appiconset contains placeholder Contents.json
- Actual icon images need to be created and added
- Use this guide when working with a designer or creating yourself
- All icon files should be placed in: `MealPrepVisionTracker/Resources/Assets.xcassets/AppIcon.appiconset/`
