//
//  RecipeAIService.swift
//  MealPrepVisionTracker
//
//  Created on 12/04/2025.
//

import UIKit
import Vision

enum RecipeAIError: LocalizedError {
    case invalidImage
    case noFoodDetected
    case aiProcessingFailed(String)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image provided"
        case .noFoodDetected:
            return "No food items detected in the image"
        case .aiProcessingFailed(let message):
            return "AI processing failed: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

struct DetectedRecipe {
    let name: String
    let description: String
    let ingredients: [DetectedIngredient]
    let instructions: [String]
    let estimatedPrepTime: Int // minutes
    let estimatedServings: Int
    let cuisineType: String?
    let confidence: Float
    let detectedFoodItems: [String] // What the AI saw in the image
}

struct DetectedIngredient {
    let name: String
    let quantity: String
    let unit: String?
}

class RecipeAIService {
    
    static let shared = RecipeAIService()
    
    // Using OpenAI's GPT-4 Vision API for recipe generation
    // You can also use Google Cloud Vision, AWS Rekognition, or other services
    private let openAIKey = "YOUR_OPENAI_API_KEY" // Replace with your key
    private let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    
    private init() {}
    
    // MARK: - Main Recipe Generation
    
    func generateRecipeFromImage(_ image: UIImage, completion: @escaping (Result<DetectedRecipe, RecipeAIError>) -> Void) {
        // Step 1: Detect food items using Vision framework
        detectFoodItems(in: image) { [weak self] result in
            switch result {
            case .success(let foodItems):
                guard !foodItems.isEmpty else {
                    completion(.failure(.noFoodDetected))
                    return
                }
                
                // Step 2: Use AI to generate recipe based on detected items
                self?.generateRecipeWithAI(foodItems: foodItems, image: image, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Vision Framework Food Detection
    
    private func detectFoodItems(in image: UIImage, completion: @escaping (Result<[String], RecipeAIError>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(.invalidImage))
            return
        }
        
        let request = VNClassifyImageRequest { request, error in
            if let error = error {
                completion(.failure(.aiProcessingFailed(error.localizedDescription)))
                return
            }
            
            guard let observations = request.results as? [VNClassificationObservation] else {
                completion(.failure(.noFoodDetected))
                return
            }
            
            // Filter for food-related items with confidence > 0.3
            let foodItems = observations
                .filter { $0.confidence > 0.3 && self.isFoodRelated($0.identifier) }
                .prefix(10)
                .map { $0.identifier.replacingOccurrences(of: "_", with: " ").capitalized }
            
            completion(.success(Array(foodItems)))
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(.aiProcessingFailed(error.localizedDescription)))
            }
        }
    }
    
    // MARK: - AI Recipe Generation (OpenAI GPT-4 Vision)
    
    private func generateRecipeWithAI(foodItems: [String], image: UIImage, completion: @escaping (Result<DetectedRecipe, RecipeAIError>) -> Void) {
        
        // Check if API key is configured
        guard openAIKey != "YOUR_OPENAI_API_KEY" else {
            // Fallback to mock recipe generation
            let mockRecipe = generateMockRecipe(from: foodItems)
            completion(.success(mockRecipe))
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(.invalidImage))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // Create OpenAI request
        let prompt = """
        Analyze this food image and create a detailed recipe. Based on what you see, provide:
        1. Recipe name
        2. Brief description
        3. List of ingredients with quantities
        4. Step-by-step cooking instructions
        5. Estimated prep time in minutes
        6. Number of servings
        7. Cuisine type
        
        Format your response as JSON with this structure:
        {
            "name": "Recipe Name",
            "description": "Brief description",
            "ingredients": [{"name": "ingredient", "quantity": "amount", "unit": "unit"}],
            "instructions": ["Step 1", "Step 2", ...],
            "prepTime": 30,
            "servings": 4,
            "cuisineType": "cuisine"
        }
        """
        
        let payload: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                    ]
                ]
            ],
            "max_tokens": 1000
        ]
        
        guard let url = URL(string: openAIEndpoint),
              let requestData = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(.failure(.aiProcessingFailed("Invalid request")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.aiProcessingFailed("No response data")))
                return
            }
            
            do {
                let recipe = try self.parseOpenAIResponse(data, detectedItems: foodItems)
                completion(.success(recipe))
            } catch {
                // Fallback to mock if parsing fails
                let mockRecipe = self.generateMockRecipe(from: foodItems)
                completion(.success(mockRecipe))
            }
        }.resume()
    }
    
    // MARK: - Response Parsing
    
    private func parseOpenAIResponse(_ data: Data, detectedItems: [String]) throws -> DetectedRecipe {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw RecipeAIError.aiProcessingFailed("Invalid response format")
        }
        
        // Parse the JSON content from the response
        guard let jsonData = content.data(using: .utf8),
              let recipeJSON = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw RecipeAIError.aiProcessingFailed("Could not parse recipe JSON")
        }
        
        let name = recipeJSON["name"] as? String ?? "Generated Recipe"
        let description = recipeJSON["description"] as? String ?? ""
        let prepTime = recipeJSON["prepTime"] as? Int ?? 30
        let servings = recipeJSON["servings"] as? Int ?? 4
        let cuisineType = recipeJSON["cuisineType"] as? String
        
        let ingredientsArray = recipeJSON["ingredients"] as? [[String: String]] ?? []
        let ingredients = ingredientsArray.map { dict in
            DetectedIngredient(
                name: dict["name"] ?? "",
                quantity: dict["quantity"] ?? "1",
                unit: dict["unit"]
            )
        }
        
        let instructions = recipeJSON["instructions"] as? [String] ?? ["No instructions provided"]
        
        return DetectedRecipe(
            name: name,
            description: description,
            ingredients: ingredients,
            instructions: instructions,
            estimatedPrepTime: prepTime,
            estimatedServings: servings,
            cuisineType: cuisineType,
            confidence: 0.85,
            detectedFoodItems: detectedItems
        )
    }
    
    // MARK: - Mock Recipe Generation (Fallback)
    
    private func generateMockRecipe(from foodItems: [String]) -> DetectedRecipe {
        let recipeName = generateRecipeName(from: foodItems)
        let ingredients = foodItems.prefix(5).map { item in
            DetectedIngredient(name: item, quantity: "1", unit: "serving")
        }
        
        let instructions = [
            "Prepare all ingredients and wash thoroughly",
            "Combine \(foodItems.prefix(2).joined(separator: " and ")) in a bowl",
            "Cook or mix according to your preference",
            "Season to taste and serve"
        ]
        
        return DetectedRecipe(
            name: recipeName,
            description: "A delicious recipe featuring \(foodItems.prefix(3).joined(separator: ", "))",
            ingredients: Array(ingredients),
            instructions: instructions,
            estimatedPrepTime: 30,
            estimatedServings: 4,
            cuisineType: nil,
            confidence: 0.7,
            detectedFoodItems: foodItems
        )
    }
    
    // MARK: - Helper Methods
    
    private func isFoodRelated(_ identifier: String) -> Bool {
        let foodKeywords = [
            "food", "meal", "dish", "cuisine", "fruit", "vegetable", "meat", "seafood",
            "pasta", "rice", "bread", "salad", "soup", "dessert", "snack", "breakfast",
            "lunch", "dinner", "chicken", "beef", "pork", "fish", "cheese", "egg",
            "tomato", "potato", "carrot", "pizza", "burger", "sandwich", "taco", "sushi",
            "noodle", "cake", "cookie", "pie", "sauce", "spice"
        ]
        
        let lowerIdentifier = identifier.lowercased()
        return foodKeywords.contains { lowerIdentifier.contains($0) }
    }
    
    private func generateRecipeName(from items: [String]) -> String {
        if items.isEmpty {
            return "Mystery Dish"
        } else if items.count == 1 {
            return "\(items[0]) Delight"
        } else {
            return "\(items[0]) and \(items[1]) Special"
        }
    }
}
