# Core ML Model Training Guide

## Creating a Custom Ingredient Classifier

### Prerequisites
- macOS with Xcode 14+
- Create ML framework
- Training data (ingredient images)

### Training Data Structure
```
TrainingData/
├── vegetables/
│   ├── tomato1.jpg
│   ├── carrot1.jpg
│   └── ...
├── fruits/
│   ├── apple1.jpg
│   ├── banana1.jpg
│   └── ...
├── proteins/
│   ├── chicken1.jpg
│   ├── beef1.jpg
│   └── ...
├── dairy/
│   ├── milk1.jpg
│   ├── cheese1.jpg
│   └── ...
└── grains/
    ├── bread1.jpg
    ├── rice1.jpg
    └── ...
```

### Training Code (Swift Playground)
```swift
import CreateML
import Foundation

let dataURL = URL(fileURLWithPath: "/path/to/TrainingData")

do {
    // Create image classifier
    let classifier = try MLImageClassifier(trainingData: .labeledDirectories(at: dataURL))
    
    // Save the model
    try classifier.write(to: URL(fileURLWithPath: "/path/to/IngredientClassifier.mlmodel"))
    
    print("Model training completed successfully!")
    
    // Print evaluation metrics
    let evaluation = classifier.evaluation(on: .labeledDirectories(at: dataURL))
    print("Training accuracy: \(evaluation.classificationError)")
    
} catch {
    print("Error during training: \(error)")
}
```

### Integration Steps
1. Train your model using the code above
2. Replace the placeholder `IngredientClassifier.mlmodel` file
3. Add the model to your Xcode project
4. Build and run the app

### Model Performance Tips
- Use at least 10-50 images per category
- Include variety (different angles, lighting, backgrounds)
- Use high-quality images (min 224x224 pixels)
- Test with validation data separate from training data

### Fallback Behavior
If no custom model is found, the app automatically falls back to Vision's built-in image classifier.