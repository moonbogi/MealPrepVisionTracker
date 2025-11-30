# Meal Prep Vision Tracker - Setup Guide

## Quick Start

### Prerequisites
- macOS with Xcode 13.0 or later
- iOS device or simulator running iOS 14.0+
- Basic understanding of Swift and UIKit

### Installation Steps

1. **Open the Project**
   ```bash
   cd MealPrepVisionTracker
   open MealPrepVisionTracker.xcodeproj
   ```

2. **Configure Signing**
   - Select the project in Xcode
   - Go to "Signing & Capabilities"
   - Select your development team
   - Xcode will automatically manage signing

3. **Build & Run**
   - Select a target device/simulator
   - Press `Cmd + R`
   - The app will build and launch

## Project Configuration

### Info.plist Settings
Already configured for you:
- `NSCameraUsageDescription`: Camera permission
- `NSPhotoLibraryUsageDescription`: Photo library permission
- No Main Storyboard (fully programmatic)
- Scene-based lifecycle

### Build Settings
Recommended:
- **Deployment Target**: iOS 14.0
- **Swift Language Version**: Swift 5
- **Optimization Level**: None (Debug), Speed (Release)

## Testing on Device

### Camera Features
- **Simulator**: Use photo library only (no camera)
- **Physical Device**: Full camera and photo library access

### Permissions
On first launch, the app will request:
1. Camera access (when opening Scan tab)
2. Photo library access (when selecting photos)

Grant permissions to enable full functionality.

## Custom ML Model Integration

### Step 1: Train Your Model
Use Create ML to train an ingredient classifier:
```
1. Collect ~50+ images per ingredient category
2. Open Create ML app
3. Create Image Classification project
4. Import training/validation data
5. Train model
6. Export as .mlmodel file
```

### Step 2: Add Model to Project
```
1. Drag .mlmodel file into Xcode project
2. Ensure "Target Membership" is checked
3. Xcode automatically generates Swift interface
```

### Step 3: Update VisionService
In `VisionService.swift`, replace:
```swift
private func createCustomModel() -> MLModel {
    let configuration = MLModelConfiguration()
    // Replace "YourModelName" with your .mlmodel filename
    return try! YourModelName(configuration: configuration).model
}
```

## Architecture Overview

### No Storyboards
- All UI created programmatically
- `SceneDelegate` sets window root view controller
- Tab bar navigation structure
- Auto Layout with NSLayoutConstraint

### Data Flow
```
User Action → ViewController → Service → Model → Persistence
     ↑                                              ↓
     └──────────────── Update UI ──────────────────┘
```

### Services
- **VisionService**: Image recognition
- **RecipeService**: Recipe matching logic
- **PersistenceManager**: Data storage

## Development Tips

### Adding New View Controllers
1. Create new `.swift` file in `ViewControllers/`
2. Subclass `UIViewController`
3. Override `viewDidLoad()`
4. Create UI elements programmatically
5. Setup constraints with `NSLayoutConstraint.activate()`

Example:
```swift
class NewViewController: UIViewController {
    private let myLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(myLabel)
        NSLayoutConstraint.activate([
            myLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            myLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
```

### Debugging Vision
- Print confidence scores
- Lower threshold in `VisionService` (line 46)
- Test with clear, well-lit photos
- Use common ingredients for better recognition

### Sample Data
- Recipes in `RecipeService.loadSampleRecipes()`
- Add more recipes by appending to array
- Follow existing `Recipe` structure

## Common Issues

### Camera Not Working
- Check Info.plist permissions
- Verify camera access in Settings > Privacy
- Use physical device (simulator has no camera)

### No Ingredients Detected
- Vision framework uses built-in classifier initially
- Results may be generic without custom model
- Train custom Create ML model for better accuracy

### Build Errors
- Clean build folder: `Cmd + Shift + K`
- Delete DerivedData: `~/Library/Developer/Xcode/DerivedData`
- Restart Xcode

## Performance Optimization

### Vision Processing
- Runs on background thread (`DispatchQueue.global()`)
- UI updates on main thread (`DispatchQueue.main.async`)
- Images compressed before storage

### Data Storage
- UserDefaults for small datasets
- Consider Core Data for 100+ recipes/ingredients
- JSON encoding/decoding for Codable models

## Next Steps

1. **Test the App**: Run and explore all features
2. **Add Recipes**: Customize sample recipes
3. **Train Model**: Create custom ingredient classifier
4. **Customize UI**: Adjust colors, fonts, layouts
5. **Add Features**: Implement ideas from README

## Resources

- [Apple Vision Framework](https://developer.apple.com/documentation/vision)
- [Create ML](https://developer.apple.com/machine-learning/create-ml/)
- [UIKit Documentation](https://developer.apple.com/documentation/uikit)
- [Auto Layout Guide](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/)

## Support

For questions or issues:
1. Check this setup guide
2. Review code comments
3. Consult Apple documentation
4. Search Stack Overflow

Happy coding! 🚀
