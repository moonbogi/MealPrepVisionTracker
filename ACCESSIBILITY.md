# Accessibility Guide

## Overview
This document outlines the accessibility features and best practices implemented in Meal Prep Vision Tracker.

## VoiceOver Support

### Navigation Labels
All interactive elements have descriptive accessibility labels:

**Tab Bar Items:**
- "Scan" - Camera scanning tab
- "Pantry" - Ingredients management tab
- "Recipes" - Recipe suggestions tab  
- "Nutrition" - Nutrition tracking tab

**Buttons:**
- "Next page" - Onboarding next button
- "Skip tutorial" - Onboarding skip button
- "Get started with the app" - Final onboarding button
- "Add ingredient manually" - Plus button in Pantry
- "Recipe filter" - Segmented control in Recipes
- "Scan ingredient" - Empty state action button

### Screen Readers
All screens announce their purpose:
- "Ingredients list" - Pantry table view
- "Recipes list" - Recipes table view
- Section headers use `.header` trait
- Empty states are properly announced

## Dynamic Type

### Font Support
All text labels support Dynamic Type with `adjustsFontForContentSizeCategory`:

**Supported Text Styles:**
- Titles: `.title1`, `.title2`, `.title3`
- Body: `.body`, `.callout`
- Captions: `.caption1`, `.caption2`
- Headlines: `.headline`, `.subheadline`

**Implementation:**
```swift
label.adjustsFontForContentSizeCategory = true
label.font = .preferredFont(forTextStyle: .body)
```

### Testing Dynamic Type
1. Settings > Accessibility > Display & Text Size > Larger Text
2. Test at various text sizes (XS to XXXL)
3. Ensure no text truncation
4. Verify button sizing accommodates larger text

## Color Contrast

### WCAG 2.1 Compliance
All text meets minimum contrast ratios:
- Normal text: 4.5:1 minimum
- Large text (18pt+): 3:1 minimum
- UI components: 3:1 minimum

**Color Combinations:**
- Primary text on background: 15.8:1 (Label on SystemBackground)
- Secondary text: 7.0:1 (SecondaryLabel)
- Brand green: 4.5:1+ on white/black

### Dark Mode
Fully supports dark appearance:
- All colors use semantic system colors
- Custom brand green adjusts for dark mode
- Icons use adaptive SF Symbols
- No hardcoded colors that break in dark mode

## Reduced Motion

### Respecting User Preferences
```swift
if UIAccessibility.isReduceMotionEnabled {
    // Use instant transitions instead of animations
    view.alpha = 1.0
} else {
    UIView.animate(withDuration: 0.3) {
        view.alpha = 1.0
    }
}
```

**Implemented in:**
- Onboarding page transitions (simpler when reduced motion enabled)
- Tab bar transitions
- Alert presentations

## Accessibility Identifiers

### For UI Testing
All key UI elements have accessibility identifiers:

**View Controllers:**
- "OnboardingViewController"
- "CameraViewController"
- "IngredientsViewController"
- "RecipesViewController"
- "NutritionViewController"

**Common Elements:**
- "ingredientCell_\(ingredient.id)"
- "recipeCell_\(recipe.id)"
- "scanButton"
- "addIngredientButton"

## Keyboard Navigation

### Focus Management
- Logical tab order for keyboard users
- First responder management in forms
- Return key navigation in text fields
- Escape key dismisses modals

### Shortcuts (Future Enhancement)
Potential keyboard shortcuts:
- Cmd+N: New ingredient
- Cmd+F: Search
- Cmd+1,2,3,4: Switch tabs

## Testing Checklist

### VoiceOver Testing
- [ ] Turn on VoiceOver (Settings > Accessibility > VoiceOver)
- [ ] Navigate through all screens
- [ ] Verify all buttons are labeled
- [ ] Check custom controls announce properly
- [ ] Test empty states
- [ ] Verify table cell announcements
- [ ] Check image descriptions

### Dynamic Type Testing
- [ ] Enable largest text size
- [ ] Verify all text is readable
- [ ] Check button hit areas (min 44x44pt)
- [ ] Ensure no text truncation
- [ ] Test onboarding flow
- [ ] Verify recipe cards scale properly

### Color & Contrast
- [ ] Test in light mode
- [ ] Test in dark mode
- [ ] Use Accessibility Inspector contrast check
- [ ] Verify all icons are visible
- [ ] Check disabled state visibility

### Motion & Animation
- [ ] Enable Reduce Motion
- [ ] Verify transitions work without animation
- [ ] Check onboarding respects preference
- [ ] Test alert presentations

### Additional Checks
- [ ] Enable Increase Contrast
- [ ] Test with Differentiate Without Color
- [ ] Try with On/Off Labels (switches)
- [ ] Test with Reduce Transparency
- [ ] Verify with Button Shapes enabled

## Accessibility Inspector

### Using Xcode's Accessibility Inspector

**Location:** Xcode > Open Developer Tool > Accessibility Inspector

**Features:**
1. **Inspection Mode** - Click elements to see properties
2. **Audit** - Automated accessibility checks
3. **Settings** - Simulate accessibility features
4. **Color Contrast** - Check text contrast ratios

**Common Issues to Check:**
- Missing labels
- Low contrast text
- Small hit areas (< 44x44pt)
- Unlabeled images
- Ambiguous labels

## Best Practices Implemented

### 1. Semantic Labels
```swift
// ✅ Good
button.accessibilityLabel = "Add ingredient to pantry"

// ❌ Bad
button.accessibilityLabel = "Add"
```

### 2. Accessibility Traits
```swift
titleLabel.accessibilityTraits = .header
deleteButton.accessibilityTraits = .button
imageView.isAccessibilityElement = false // Decorative
```

### 3. Accessibility Hints
```swift
scanButton.accessibilityHint = "Opens camera to scan ingredients"
```

### 4. Grouped Elements
```swift
// Group related elements
containerView.isAccessibilityElement = true
containerView.accessibilityLabel = "Recipe: \(recipe.name), \(recipe.prepTime) minutes"
```

### 5. Custom Controls
All custom controls properly implement UIAccessibility:
- EmptyStateView
- OnboardingPageViewController
- Custom cells

## Localization Support

### Accessible in All Languages
- VoiceOver works in all iOS languages
- UI elements scale for longer translations
- RTL (Right-to-Left) support for Arabic/Hebrew
- Number and date formatting respect locale

## Known Limitations & Future Improvements

### Current Limitations
- Camera scanning requires visual capability (alternative: manual entry provided)
- Recipe images are decorative (descriptions in alt text)
- No haptic feedback for actions (future enhancement)

### Planned Improvements
1. **Voice Commands**
   - Siri shortcuts for common actions
   - Voice-guided ingredient scanning

2. **Haptic Feedback**
   - Scan success feedback
   - Ingredient added confirmation
   - Error states

3. **Audio Cues**
   - Sound effects for actions (optional)
   - Audio descriptions for complex visuals

4. **Enhanced VoiceOver**
   - More detailed image descriptions
   - Nutritional information audio summaries
   - Recipe step-by-step audio guidance

## Resources

### Apple Documentation
- [Accessibility Programming Guide](https://developer.apple.com/accessibility/)
- [WWDC Accessibility Sessions](https://developer.apple.com/videos/accessibility/)
- [UIAccessibility Reference](https://developer.apple.com/documentation/uikit/accessibility)

### Testing Tools
- **Accessibility Inspector** - Built into Xcode
- **Voice Control** - iOS Settings > Accessibility
- **Switch Control** - For users with limited mobility
- **Color Contrast Analyzer** - Third-party tool

### Guidelines
- **WCAG 2.1** - Web Content Accessibility Guidelines
- **Section 508** - US Federal accessibility standards
- **EN 301 549** - European accessibility standard

## Support

Users with accessibility questions can contact:
- Email: accessibility@mealpreptrackerapp.com
- Feedback via App Store reviews
- GitHub Issues for technical problems

## Continuous Improvement

We're committed to making Meal Prep Vision Tracker accessible to everyone. Please report accessibility issues via:
1. App Store reviews
2. GitHub issues
3. Direct email to support

All accessibility bugs are prioritized and typically fixed in the next update.
