//
//  NutritionixService.swift
//  MealPrepVisionTracker
//
//  Created on 12/04/2025.
//

import Foundation

enum NutritionixError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case apiError(String)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API request"
        case .noData:
            return "No data received from server"
        case .decodingError:
            return "Failed to parse ingredient data"
        case .apiError(let message):
            return "API Error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - API Response Models

struct NutritionixSearchResponse: Codable {
    let common: [NutritionixCommonFood]
    let branded: [NutritionixBrandedFood]
}

struct NutritionixCommonFood: Codable {
    let foodName: String
    let servingUnit: String
    let servingQty: Double
    let photoThumbURL: String?
    
    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case servingUnit = "serving_unit"
        case servingQty = "serving_qty"
        case photoThumbURL = "photo"
    }
}

struct NutritionixBrandedFood: Codable {
    let foodName: String
    let brandName: String?
    let servingUnit: String
    let servingQty: Double
    let photoThumbURL: String?
    
    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case brandName = "brand_name"
        case servingUnit = "serving_unit"
        case servingQty = "serving_qty"
        case photoThumbURL = "photo"
    }
}

struct NutritionixNutrientResponse: Codable {
    let foods: [NutritionixFood]
}

struct NutritionixFood: Codable {
    let foodName: String
    let servingQty: Double
    let servingUnit: String
    let servingWeightGrams: Double?
    let calories: Double
    let totalFat: Double
    let protein: Double
    let totalCarbohydrate: Double
    let photoThumbURL: String?
    
    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case servingQty = "serving_qty"
        case servingUnit = "serving_unit"
        case servingWeightGrams = "serving_weight_grams"
        case calories = "nf_calories"
        case totalFat = "nf_total_fat"
        case protein = "nf_protein"
        case totalCarbohydrate = "nf_total_carbohydrate"
        case photoThumbURL = "photo"
    }
}

// MARK: - Nutritionix Service

class NutritionixService {
    
    static let shared = NutritionixService()
    
    // TODO: Get your own API keys from https://developer.nutritionix.com/
    // These are example keys - replace with your own!
    private let appId = "YOUR_APP_ID"
    private let appKey = "YOUR_APP_KEY"
    
    private let baseURL = "https://trackapi.nutritionix.com/v2"
    
    private init() {}
    
    // MARK: - Search Ingredients
    
    func searchIngredients(query: String, completion: @escaping (Result<[NutritionixCommonFood], NutritionixError>) -> Void) {
        guard !query.isEmpty else {
            completion(.success([]))
            return
        }
        
        // Check if API keys are configured
        guard appId != "YOUR_APP_ID" && appKey != "YOUR_APP_KEY" else {
            completion(.failure(.apiError("API keys not configured. Please add your Nutritionix API keys in NutritionixService.swift")))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/search/instant?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(appId, forHTTPHeaderField: "x-app-id")
        request.setValue(appKey, forHTTPHeaderField: "x-app-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // Check for HTTP errors
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    completion(.failure(.apiError("Invalid API credentials. Please check your Nutritionix API keys.")))
                    return
                } else if httpResponse.statusCode != 200 {
                    // Try to parse error message from response
                    if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = errorDict["message"] as? String {
                        completion(.failure(.apiError(message)))
                    } else {
                        completion(.failure(.apiError("API request failed with status code \(httpResponse.statusCode)")))
                    }
                    return
                }
            }
            
            do {
                let searchResponse = try JSONDecoder().decode(NutritionixSearchResponse.self, from: data)
                completion(.success(searchResponse.common))
            } catch {
                // Log the actual error for debugging
                print("Decoding error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response data: \(jsonString.prefix(200))")
                }
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    // MARK: - Get Ingredient Details
    
    func getIngredientDetails(query: String, completion: @escaping (Result<NutritionixFood, NutritionixError>) -> Void) {
        // Check if API keys are configured
        guard appId != "YOUR_APP_ID" && appKey != "YOUR_APP_KEY" else {
            completion(.failure(.apiError("API keys not configured. Please add your Nutritionix API keys in NutritionixService.swift")))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/natural/nutrients") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(appId, forHTTPHeaderField: "x-app-id")
        request.setValue(appKey, forHTTPHeaderField: "x-app-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["query": query]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // Check for HTTP errors
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    completion(.failure(.apiError("Invalid API credentials")))
                    return
                } else if httpResponse.statusCode != 200 {
                    if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = errorDict["message"] as? String {
                        completion(.failure(.apiError(message)))
                    } else {
                        completion(.failure(.apiError("API request failed with status code \(httpResponse.statusCode)")))
                    }
                    return
                }
            }
            
            do {
                let nutrientResponse = try JSONDecoder().decode(NutritionixNutrientResponse.self, from: data)
                if let food = nutrientResponse.foods.first {
                    completion(.success(food))
                } else {
                    completion(.failure(.noData))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    // MARK: - Helper: Convert to Ingredient
    
    func convertToIngredient(from food: NutritionixCommonFood) -> Ingredient {
        let category = categorizeFood(name: food.foodName)
        let unit = mapServingUnit(food.servingUnit)
        
        return Ingredient(
            name: food.foodName.capitalized,
            category: category,
            quantity: food.servingQty,
            unit: unit,
            confidence: 1.0
        )
    }
    
    func convertToIngredient(from food: NutritionixFood) -> Ingredient {
        let category = categorizeFood(name: food.foodName)
        let unit = mapServingUnit(food.servingUnit)
        
        return Ingredient(
            name: food.foodName.capitalized,
            category: category,
            quantity: food.servingQty,
            unit: unit,
            confidence: 1.0
        )
    }
    
    // MARK: - Helper Methods
    
    private func categorizeFood(name: String) -> IngredientCategory {
        let nameLower = name.lowercased()
        
        // Vegetables
        if nameLower.contains("tomato") || nameLower.contains("lettuce") || 
           nameLower.contains("carrot") || nameLower.contains("broccoli") ||
           nameLower.contains("spinach") || nameLower.contains("pepper") ||
           nameLower.contains("onion") || nameLower.contains("celery") {
            return .vegetable
        }
        
        // Fruits
        if nameLower.contains("apple") || nameLower.contains("banana") ||
           nameLower.contains("orange") || nameLower.contains("berry") ||
           nameLower.contains("grape") || nameLower.contains("melon") {
            return .fruit
        }
        
        // Protein
        if nameLower.contains("chicken") || nameLower.contains("beef") ||
           nameLower.contains("pork") || nameLower.contains("fish") ||
           nameLower.contains("egg") || nameLower.contains("tofu") ||
           nameLower.contains("bean") || nameLower.contains("lentil") {
            return .protein
        }
        
        // Dairy
        if nameLower.contains("milk") || nameLower.contains("cheese") ||
           nameLower.contains("yogurt") || nameLower.contains("butter") ||
           nameLower.contains("cream") {
            return .dairy
        }
        
        // Grains
        if nameLower.contains("rice") || nameLower.contains("bread") ||
           nameLower.contains("pasta") || nameLower.contains("oat") ||
           nameLower.contains("flour") || nameLower.contains("cereal") {
            return .grain
        }
        
        // Spices
        if nameLower.contains("pepper") || nameLower.contains("salt") ||
           nameLower.contains("garlic") || nameLower.contains("ginger") ||
           nameLower.contains("cumin") || nameLower.contains("basil") {
            return .spice
        }
        
        return .other
    }
    
    private func mapServingUnit(_ servingUnit: String) -> MeasurementUnit {
        let unit = servingUnit.lowercased()
        
        if unit.contains("cup") { return .cup }
        if unit.contains("tbsp") || unit.contains("tablespoon") { return .tablespoon }
        if unit.contains("tsp") || unit.contains("teaspoon") { return .teaspoon }
        if unit.contains("oz") || unit.contains("ounce") { return .ounce }
        if unit.contains("lb") || unit.contains("pound") { return .pound }
        if unit.contains("g") && !unit.contains("k") { return .gram }
        if unit.contains("kg") || unit.contains("kilogram") { return .kilogram }
        if unit.contains("ml") || unit.contains("milliliter") { return .milliliter }
        if unit.contains("l") || unit.contains("liter") { return .liter }
        
        return .item
    }
}
