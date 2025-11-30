# 🍽️ Meal Prep Vision Tracker

An iOS app built with **UIKit** (fully programmatic, no storyboards) that uses **Computer Vision** and **Core ML** to identify ingredients from photos and suggest recipes based on what you have in your pantry. Perfect for busy parents managing meal prep with kids!

## ✨ Features

### 🎥 Ingredient Recognition
- **Camera Integration**: Capture photos of ingredients using the device camera
- **Photo Library Support**: Select existing photos from your library
- **Vision Framework**: Automatically identify ingredients using Apple's Vision framework
- **Core ML Ready**: Easily integrate custom trained models for better accuracy
- **Confidence Scores**: See how confident the AI is about each ingredient

### 🥗 Smart Pantry Management
- **Organized by Category**: Ingredients grouped by type (vegetables, fruits, proteins, dairy, etc.)
- **Search Functionality**: Quickly find ingredients in your pantry
- **Manual Entry**: Add ingredients manually when needed
- **Quantity Tracking**: Track amounts and units for each ingredient
- **Expiration Dates**: Track when ingredients were added

### 👨‍🍳 Recipe Matching
- **Smart Matching**: Algorithm matches your ingredients with available recipes
- **Match Percentage**: See how well you match each recipe's requirements
- **Recipe Details**: View comprehensive recipe information including:
  - Required and optional ingredients
  - Step-by-step instructions
  - Prep and cook times
  - Difficulty level
  - Serving sizes

### 📊 Nutritional Tracking
- **Daily Dashboard**: View nutritional summary for the day
- **Per-Recipe Nutrition**: Detailed nutritional information for each recipe:
  - Calories
  - Protein, Carbs, Fat
  - Fiber, Sugar
  - Sodium, Cholesterol
- **Meal Planning**: Track meals by type (breakfast, lunch, dinner, snack)
- **Date Navigation**: Browse nutrition by date

## 🏗️ Architecture

### Fully Programmatic UIKit
- **No Storyboards**: 100% programmatic UI using UIKit
- **Tab Bar Navigation**: Clean navigation between main features
- **Custom View Controllers**: Each screen built programmatically
- **Auto Layout**: Constraint-based layouts for all screen sizes

### Project Structure
```
MealPrepVisionTracker/
├── Application/
│   ├── AppDelegate.swift          # App lifecycle
│   └── SceneDelegate.swift        # Window/scene management
├── Models/
│   ├── Ingredient.swift           # Ingredient data model
│   ├── Recipe.swift               # Recipe and recipe ingredient models
│   └── NutritionalInfo.swift     # Nutrition and meal plan models
├── ViewControllers/
│   ├── MainTabBarController.swift           # Main tab bar
│   ├── CameraViewController.swift           # Camera/photo capture
│   ├── IngredientResultViewController.swift # Recognition results
│   ├── IngredientsViewController.swift      # Pantry management
│   ├── RecipesViewController.swift          # Recipe listing
│   ├── RecipeDetailViewController.swift     # Recipe details
│   └── NutritionViewController.swift        # Nutrition tracking
├── Services/
│   ├── VisionService.swift        # Computer vision processing
│   ├── RecipeService.swift        # Recipe matching logic
│   └── PersistenceManager.swift   # Data persistence
└── Resources/
    └── Assets.xcassets            # App assets
```

## 🔧 Technical Details

### Vision & Core ML
- **Built-in Classifier**: Uses `VNClassifyImageRequest` for quick testing
- **Custom Model Support**: Ready to integrate Create ML trained models
- **Image Processing**: Efficient CIImage processing
- **Confidence Filtering**: Configurable confidence thresholds

### Data Persistence
- **UserDefaults**: Lightweight storage for ingredients and meal plans
- **JSON Encoding**: Codable models for easy serialization
- **Future-Ready**: Architecture supports migration to Core Data

### Recipe Matching Algorithm
- **Weighted Scoring**: Required ingredients (80%) + Optional ingredients (20%)
- **Threshold Filtering**: Only shows recipes with 50%+ match
- **Sorted Results**: Recipes ranked by match percentage

## 📱 Requirements

- **iOS 14.0+**
- **Xcode 13.0+**
- **Swift 5.5+**
- **Camera-enabled device** (for scanning)

## 🚀 Getting Started

### 1. Open the Project
```bash
cd MealPrepVisionTracker
open MealPrepVisionTracker.xcodeproj
```

### 2. Build and Run
- Select your target device or simulator
- Press `Cmd + R` to build and run

### 3. Permissions
The app requires:
- **Camera Access**: To capture ingredient photos
- **Photo Library Access**: To select photos

Permissions are requested at runtime and configured in `Info.plist`.

## 🎯 Usage Guide

### Scanning Ingredients
1. Open the **Scan** tab
2. Tap the camera button to take a photo
3. Or tap the photo icon to select from library
4. Review detected ingredients
5. Remove any incorrect detections
6. Tap "Save to Pantry"

### Managing Pantry
1. Open the **Pantry** tab
2. Browse ingredients by category
3. Use search to find specific items
4. Tap "+" to add ingredients manually
5. Swipe left to delete items

### Finding Recipes
1. Open the **Recipes** tab
2. View "Matches" to see recipes you can make
3. Match percentage shows ingredient availability
4. Switch to "All Recipes" to browse everything
5. Tap a recipe to see details

### Tracking Nutrition
1. Open the **Nutrition** tab
2. View daily nutritional summary
3. See meal plans for the selected date
4. Use navigation buttons to change dates
5. Tap "Today" to return to current date

## 🔮 Future Enhancements

### Computer Vision
- [ ] Train custom Create ML model with food dataset
- [ ] Add object detection for multiple ingredients in one photo
- [ ] Implement barcode scanning for packaged foods
- [ ] Add text recognition for nutrition labels

### Features
- [ ] Shopping list generation from missing recipe ingredients
- [ ] Meal planning calendar view
- [ ] Recipe import from URLs
- [ ] User-created recipes
- [ ] Social sharing of recipes
- [ ] Dietary restrictions/preferences filtering
- [ ] Portion size calculator

### Data & Analytics
- [ ] Migrate to Core Data for better performance
- [ ] Weekly/monthly nutrition trends
- [ ] Goal tracking (calorie, protein targets)
- [ ] Food waste tracking
- [ ] Cost estimation per meal

### ML/AI Enhancements
- [ ] Personalized recipe recommendations
- [ ] Learn user preferences over time
- [ ] Suggest substitutions for missing ingredients
- [ ] Predict expiration dates based on ingredient type

## 🧪 Training Your Own Model

### Using Create ML
1. Collect ingredient images (at least 50 per category)
2. Open Create ML app
3. Create new Image Classification project
4. Import training data
5. Train the model
6. Export as `.mlmodel` file
7. Add to Xcode project
8. Update `VisionService.swift` to load your model:

```swift
private func createCustomModel() -> MLModel {
    // Replace with your model name
    let configuration = MLModelConfiguration()
    return try! IngredientClassifier(configuration: configuration).model
}
```

## 🎨 Customization

### Adding New Ingredient Categories
Edit `IngredientCategory` enum in `Ingredient.swift`:
```swift
enum IngredientCategory: String, Codable, CaseIterable {
    case yourCategory
    // ... other cases
    
    var emoji: String {
        switch self {
        case .yourCategory: return "🥘"
        // ... other cases
        }
    }
}
```

### Adding More Recipes
Edit `RecipeService.swift` in the `loadSampleRecipes()` method to add more recipe data.

## 🤝 Contributing

This is a personal project, but suggestions and feedback are welcome! Feel free to:
- Report bugs
- Suggest features
- Share your trained ML models
- Submit pull requests

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

Built with ❤️ for busy parents managing meal prep!

---

## 📝 Notes

- **No Storyboards**: This entire app is built programmatically for maximum flexibility
- **Vision Framework**: Uses Apple's built-in Vision for quick testing; swap in custom models for production
- **Family-Focused**: Designed with the pain points of parents in mind
- **Computer Vision**: Complements CLIP work from movie recommendation projects

**Perfect for**: iOS developers learning computer vision, families managing meal prep, anyone interested in practical ML applications!
