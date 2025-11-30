# RIBs Architecture Guide

## 🏗️ Architecture Overview

This app now uses **RIBs (Router-Interactor-Builder)** architecture from Uber, providing:
- ✅ **Strong separation of concerns**
- ✅ **Dependency injection**
- ✅ **Testability**
- ✅ **Scalability**
- ✅ **Clear business logic**

## 📐 RIBs Components

### **Builder**
- Creates and wires all components
- Manages dependency injection
- Returns a configured Router

### **Interactor**
- Contains business logic
- Handles user interactions
- Communicates with services
- Manages state

### **Router**
- Handles navigation
- Attaches/detaches child RIBs
- Manages view hierarchy

### **Presenter (ViewController)**
- Displays UI
- Forwards user actions to Interactor
- Updates UI based on Interactor commands

### **Listener**
- Protocol for parent-child communication
- Allows RIBs to notify parents of events

## 🌳 RIB Tree Structure

```
Root RIB (App Entry)
├── Camera RIB
│   └── IngredientResult (View only)
├── Ingredients RIB
├── Recipes RIB
│   └── RecipeDetail (View only)
└── Nutrition RIB
```

## 📁 File Structure

```
MealPrepVisionTracker/
├── RIBs/
│   ├── RIBs.swift                    # Base protocols & classes
│   ├── Root/
│   │   ├── RootBuilder.swift
│   │   ├── RootInteractor.swift
│   │   └── RootRouter.swift
│   ├── Camera/
│   │   ├── CameraBuilder.swift
│   │   ├── CameraInteractor.swift
│   │   ├── CameraRouter.swift
│   │   └── CameraViewController.swift
│   ├── Ingredients/
│   │   ├── IngredientsBuilder.swift
│   │   ├── IngredientsInteractor.swift
│   │   ├── IngredientsRouter.swift
│   │   └── IngredientsViewController.swift (in ViewControllers)
│   ├── Recipes/
│   │   ├── RecipesBuilder.swift
│   │   ├── RecipesInteractor.swift
│   │   ├── RecipesRouter.swift
│   │   └── RecipesViewController.swift (in ViewControllers)
│   └── Nutrition/
│       ├── NutritionBuilder.swift
│       ├── NutritionInteractor.swift
│       ├── NutritionRouter.swift
│       └── NutritionViewController.swift (in ViewControllers)
├── Services/
│   ├── VisionService.swift
│   ├── RecipeService.swift
│   └── PersistenceManager.swift
├── Models/
│   ├── Ingredient.swift
│   ├── Recipe.swift
│   └── NutritionalInfo.swift
└── Application/
    ├── AppDelegate.swift
    └── SceneDelegate.swift
```

## 🔄 Data Flow

### User Interaction Flow
```
User Tap → ViewController → Listener Protocol → Interactor → Business Logic → Service
                                                      ↓
                                                  Presenter Protocol
                                                      ↓
                                              ViewController Update
```

### Navigation Flow
```
Interactor → Router → Attach Child RIB → Update View Hierarchy
```

## 💉 Dependency Injection

### App Launch
```swift
SceneDelegate
    ↓
AppComponent (provides services)
    ↓
RootBuilder.build()
    ↓
RootComponent (dependency container)
    ↓
Feature Builders (Camera, Ingredients, etc.)
```

### Example: Camera RIB Dependencies
```swift
protocol CameraDependency {
    var visionService: VisionService { get }
    var persistenceManager: PersistenceManager { get }
}
```

## 🎯 Key Patterns

### 1. **Builder Pattern**
```swift
protocol CameraBuildable {
    func build(withListener listener: CameraListener) -> ViewableRouting
}
```

### 2. **Listener Pattern**
```swift
protocol CameraListener: AnyObject {
    // Parent receives events from Camera
}
```

### 3. **Presentable Pattern**
```swift
protocol CameraPresentable {
    func showLoading()
    func hideLoading()
}
```

## 🧪 Testing Benefits

### Interactor Testing
```swift
// Mock dependencies
let mockVisionService = MockVisionService()
let mockPersistence = MockPersistenceManager()

// Create interactor with mocks
let interactor = CameraInteractor(
    presenter: mockPresenter,
    visionService: mockVisionService,
    persistenceManager: mockPersistence
)

// Test business logic without UI
interactor.didCaptureImage(testImage)
XCTAssertTrue(mockPresenter.showLoadingCalled)
```

### Router Testing
```swift
// Test navigation without actual view controllers
let mockRouter = MockCameraRouter()
interactor.router = mockRouter

interactor.didCaptureImage(testImage)
XCTAssertTrue(mockRouter.routeToResultCalled)
```

## 📝 Adding a New Feature

### Step 1: Create Builder
```swift
protocol NewFeatureDependency: Dependency {
    var someService: SomeService { get }
}

final class NewFeatureBuilder: NewFeatureBuildable {
    func build(withListener listener: NewFeatureListener) -> ViewableRouting {
        // Wire components
    }
}
```

### Step 2: Create Interactor
```swift
final class NewFeatureInteractor: Interactor, NewFeaturePresentableListener {
    weak var router: NewFeatureRouting?
    weak var listener: NewFeatureListener?
    
    // Business logic here
}
```

### Step 3: Create Router
```swift
final class NewFeatureRouter: ViewableRouter<NewFeatureInteractor, NewFeatureViewController>, NewFeatureRouting {
    func routeToChildFeature() {
        // Navigation logic
    }
}
```

### Step 4: Create ViewController
```swift
final class NewFeatureViewController: UIViewController, NewFeaturePresentable {
    weak var listener: NewFeaturePresentableListener?
    
    // UI code
}
```

### Step 5: Integrate with Parent
```swift
// In parent router
let newFeatureRouter = newFeatureBuilder.build(withListener: interactor)
attachChild(newFeatureRouter)
```

## 🔍 RIBs vs MVC

| Aspect | MVC | RIBs |
|--------|-----|------|
| Business Logic | In ViewController | In Interactor |
| Navigation | Coupled to VC | Separate Router |
| Testability | Hard to test UI | Easy to test logic |
| Dependencies | Implicit/singletons | Explicit injection |
| Scalability | Gets messy | Scales well |
| Boilerplate | Less | More |

## 💡 Best Practices

### ✅ DO
- Keep Interactors focused on business logic
- Use Listeners for parent-child communication
- Inject all dependencies through Builders
- Make ViewControllers dumb (just UI)
- Test Interactors and Routers separately

### ❌ DON'T
- Don't put business logic in ViewControllers
- Don't use singletons inside RIBs (inject them)
- Don't access child RIBs directly
- Don't skip the Builder pattern
- Don't make Routers too complex

## 🚀 Benefits for This App

### Before (MVC)
- ViewControllers had 200+ lines
- Business logic mixed with UI
- Hard to test
- Tight coupling to services

### After (RIBs)
- Clear separation of concerns
- Interactors testable without UI
- Dependency injection throughout
- Easy to add new features
- Navigation centralized in Routers

## 📚 Further Reading

- [Uber RIBs GitHub](https://github.com/uber/RIBs)
- [RIBs Documentation](https://github.com/uber/RIBs/wiki)
- [iOS RIBs Tutorial](https://github.com/uber/RIBs/wiki/iOS-Tutorial-1)

## 🎓 Example: Camera Flow

### 1. User opens app
```swift
SceneDelegate → RootBuilder → RootRouter → CameraBuilder
```

### 2. User taps capture button
```swift
CameraViewController (capturePhoto)
    ↓
listener.didCaptureImage()
    ↓
CameraInteractor.didCaptureImage()
    ↓
visionService.recognizeIngredients()
    ↓
presenter.showLoading()
```

### 3. Results received
```swift
CameraInteractor (success)
    ↓
router.routeToIngredientResult()
    ↓
CameraRouter.routeToIngredientResult()
    ↓
Push IngredientResultViewController
```

### 4. User saves ingredients
```swift
IngredientResultViewController (save button)
    ↓
PersistenceManager.addIngredient()
    ↓
listener.didDismissIngredientResult()
    ↓
CameraRouter.dismissIngredientResult()
```

---

**This RIBs architecture makes the app enterprise-ready and highly maintainable!** 🎉
