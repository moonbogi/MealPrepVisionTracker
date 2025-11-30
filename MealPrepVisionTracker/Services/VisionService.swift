//
//  VisionService.swift
//  MealPrepVisionTracker
//
//  Created on 11/26/2025.
//

import UIKit
import Vision
import CoreML

enum VisionError: LocalizedError {
    case invalidImage
    case noResults
    case modelLoadingFailed
    case processingTimeout
    case insufficientMemory
    case cameraNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The selected image could not be processed. Please try a different photo."
        case .noResults:
            return "No ingredients could be identified in this image. Try taking a clearer photo with better lighting."
        case .modelLoadingFailed:
            return "Failed to load the recognition model. Please restart the app."
        case .processingTimeout:
            return "Image processing took too long. Please try again with a smaller image."
        case .insufficientMemory:
            return "Not enough memory to process this image. Please close other apps and try again."
        case .cameraNotAvailable:
            return "Camera is not available on this device."
        }
    }
}

class VisionService {
    
    static let shared = VisionService()
    
    private init() {}
    
    // MARK: - Ingredient Recognition
    
    func recognizeIngredients(from image: UIImage, completion: @escaping (Result<[Ingredient], Error>) -> Void) {
        // Validate image size and format
        guard image.size.width > 0 && image.size.height > 0 else {
            DispatchQueue.main.async {
                completion(.failure(VisionError.invalidImage))
            }
            return
        }
        
        guard let ciImage = CIImage(image: image) else {
            DispatchQueue.main.async {
                completion(.failure(VisionError.invalidImage))
            }
            return
        }
        
        // Use Vision framework with MobileNetV2 or custom Core ML model
        let request = createClassificationRequest { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let classifications):
                    let ingredients = self.convertClassificationsToIngredients(classifications, imageData: image.jpegData(compressionQuality: 0.8))
                    completion(.success(ingredients))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        performVisionRequest(request, on: ciImage, completion: completion)
    }
    
    // MARK: - Vision Request Creation
    
    private func createClassificationRequest(completion: @escaping (Result<[VNClassificationObservation], Error>) -> Void) -> VNImageBasedRequest {
        
        // Try to load custom Core ML model first, fallback to built-in classifier
        if let customModel = createCustomModel(),
           let visionModel = try? VNCoreMLModel(for: customModel) {
            let request = VNCoreMLRequest(model: visionModel) { request, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let observations = request.results as? [VNClassificationObservation] else {
                        completion(.failure(VisionError.noResults))
                        return
                    }
                    
                    // Filter by confidence threshold
                    let filtered = observations.filter { $0.confidence > 0.5 }
                    completion(.success(filtered))
                }
            }
            request.imageCropAndScaleOption = .centerCrop
            return request
        } else {
            // Fallback to built-in image classifier
            let request = VNClassifyImageRequest { request, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let observations = request.results as? [VNClassificationObservation] else {
                        completion(.failure(VisionError.noResults))
                        return
                    }
                    
                    // Lower confidence threshold and filter for food-related items
                    let filtered = observations.filter { $0.confidence > 0.1 }
                    let foodRelated = self.filterFoodRelatedItems(filtered)
                    
                    // If no food items found, just take top results anyway
                    let finalResults = foodRelated.isEmpty ? Array(filtered.prefix(5)) : foodRelated
                    completion(.success(finalResults))
                }
            }
            return request
        }
    }
    
    // MARK: - Custom Model Creation (Placeholder)
    
    private func createCustomModel() -> MLModel? {
        // Try to load the custom ingredient classifier model from multiple possible locations
        let possibleNames = ["IngredientClassifier", "FoodClassifier", "MealPrepClassifier"]
        let possibleExtensions = ["mlmodelc", "mlmodel"]
        
        for name in possibleNames {
            for ext in possibleExtensions {
                guard let modelURL = Bundle.main.url(forResource: name, withExtension: ext) else {
                    continue
                }
                
                do {
                    let configuration = MLModelConfiguration()
                    configuration.computeUnits = .all // Use Neural Engine if available
                    let model = try MLModel(contentsOf: modelURL, configuration: configuration)
                    print("Successfully loaded custom model: \(name).\(ext)")
                    return model
                } catch {
                    print("Failed to load model \(name).\(ext): \(error.localizedDescription)")
                    continue
                }
            }
        }
        
        print("No custom models found, using built-in Vision classifier")
        return nil
    }
    
    // MARK: - Vision Request Execution
    
    private func performVisionRequest(_ request: VNImageBasedRequest, on image: CIImage, completion: @escaping (Result<[Ingredient], Error>) -> Void) {
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        
        // Add timeout protection
        let timeoutWorkItem = DispatchWorkItem {
            DispatchQueue.main.async {
                completion(.failure(VisionError.processingTimeout))
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                timeoutWorkItem.cancel()
            } catch let error as NSError {
                timeoutWorkItem.cancel()
                DispatchQueue.main.async {
                    // Map common system errors to user-friendly errors
                    if error.code == -6 { // Memory error
                        completion(.failure(VisionError.insufficientMemory))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }
        
        // Set 30 second timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeoutWorkItem)
    }
    
    // MARK: - Convert Classifications to Ingredients
    
    private func convertClassificationsToIngredients(_ classifications: [VNClassificationObservation], imageData: Data?) -> [Ingredient] {
        var ingredients: [Ingredient] = []
        
        for classification in classifications.prefix(5) { // Top 5 results
            let ingredientName = cleanIngredientName(classification.identifier)
            let category = categorizeIngredient(ingredientName)
            
            let ingredient = Ingredient(
                name: ingredientName,
                category: category,
                quantity: 1.0,
                unit: .item,
                imageData: imageData,
                confidence: classification.confidence
            )
            
            ingredients.append(ingredient)
        }
        
        return ingredients
    }
    
    // MARK: - Helper Methods
    
    private func filterFoodRelatedItems(_ observations: [VNClassificationObservation]) -> [VNClassificationObservation] {
        let foodKeywords = [
            // Vegetables
            "vegetable", "tomato", "lettuce", "carrot", "broccoli", "spinach", "onion", "pepper", "cucumber",
            "celery", "cabbage", "cauliflower", "potato", "mushroom", "corn", "pea", "bean", "squash",
            // Fruits
            "fruit", "apple", "banana", "orange", "grape", "strawberry", "watermelon", "lemon", "lime",
            "peach", "pear", "cherry", "berry", "melon", "mango", "pineapple", "kiwi",
            // Proteins
            "meat", "chicken", "beef", "pork", "fish", "salmon", "tuna", "shrimp", "egg", "turkey", "tofu",
            "bacon", "sausage", "ham",
            // Dairy
            "milk", "cheese", "yogurt", "butter", "cream", "dairy",
            // Grains
            "bread", "rice", "pasta", "quinoa", "oat", "wheat", "cereal", "grain", "flour",
            // General food terms
            "food", "meal", "dish", "ingredient", "produce", "edible"
        ]
        
        return observations.filter { observation in
            let identifier = observation.identifier.lowercased()
            return foodKeywords.contains { keyword in
                identifier.contains(keyword)
            }
        }
    }
    
    private func cleanIngredientName(_ rawName: String) -> String {
        // Remove common suffixes and clean up the name
        var cleaned = rawName
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
        
        // Remove taxonomy numbers and other artifacts
        if let commaIndex = cleaned.firstIndex(of: ",") {
            cleaned = String(cleaned[..<commaIndex])
        }
        
        return cleaned.trimmingCharacters(in: .whitespaces)
    }
    
    private func categorizeIngredient(_ name: String) -> IngredientCategory {
        let lowercasedName = name.lowercased()
        
        // Simple keyword-based categorization
        let vegetables = ["tomato", "lettuce", "carrot", "broccoli", "spinach", "onion", "pepper", "cucumber"]
        let fruits = ["apple", "banana", "orange", "grape", "strawberry", "watermelon", "lemon", "lime"]
        let proteins = ["chicken", "beef", "pork", "fish", "salmon", "egg", "turkey", "tofu"]
        let dairy = ["milk", "cheese", "yogurt", "butter", "cream"]
        let grains = ["bread", "rice", "pasta", "quinoa", "oat", "wheat"]
        
        if vegetables.contains(where: { lowercasedName.contains($0) }) {
            return .vegetable
        } else if fruits.contains(where: { lowercasedName.contains($0) }) {
            return .fruit
        } else if proteins.contains(where: { lowercasedName.contains($0) }) {
            return .protein
        } else if dairy.contains(where: { lowercasedName.contains($0) }) {
            return .dairy
        } else if grains.contains(where: { lowercasedName.contains($0) }) {
            return .grain
        }
        
        return .other
    }
    
    // MARK: - Object Detection (Future Enhancement - Requires iOS 17.0+)
    
    // Uncomment when targeting iOS 17.0+
    /*
    @available(iOS 17.0, *)
    func detectObjects(in image: UIImage, completion: @escaping (Result<[VNRecognizedObjectObservation], Error>) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(.failure(VisionError.invalidImage))
            return
        }
        
        let request = VNRecognizeObjectsRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedObjectObservation] else {
                completion(.failure(VisionError.noResults))
                return
            }
            
            completion(.success(observations))
        }
        
        performVisionRequest(request, on: ciImage)
    }
    */
}
