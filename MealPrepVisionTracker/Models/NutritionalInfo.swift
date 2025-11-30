//
//  NutritionalInfo.swift
//  MealPrepVisionTracker
//
//  Created on 11/26/2025.
//

import Foundation

struct NutritionalInfo: Codable, Hashable {
    let calories: Double
    let protein: Double // grams
    let carbohydrates: Double // grams
    let fat: Double // grams
    let fiber: Double // grams
    let sugar: Double // grams
    let sodium: Double // milligrams
    let cholesterol: Double // milligrams
    
    init(
        calories: Double = 0,
        protein: Double = 0,
        carbohydrates: Double = 0,
        fat: Double = 0,
        fiber: Double = 0,
        sugar: Double = 0,
        sodium: Double = 0,
        cholesterol: Double = 0
    ) {
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.cholesterol = cholesterol
    }
    
    // Calculate per serving
    func perServing(servings: Int) -> NutritionalInfo {
        guard servings > 0 else { return self }
        let divisor = Double(servings)
        return NutritionalInfo(
            calories: calories / divisor,
            protein: protein / divisor,
            carbohydrates: carbohydrates / divisor,
            fat: fat / divisor,
            fiber: fiber / divisor,
            sugar: sugar / divisor,
            sodium: sodium / divisor,
            cholesterol: cholesterol / divisor
        )
    }
}

struct MealPlan: Codable, Identifiable {
    let id: UUID
    let date: Date
    let mealType: MealType
    let recipe: Recipe
    let servings: Int
    let notes: String?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mealType: MealType,
        recipe: Recipe,
        servings: Int = 1,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.recipe = recipe
        self.servings = servings
        self.notes = notes
    }
    
    var nutritionalInfo: NutritionalInfo {
        recipe.nutritionalInfo.perServing(servings: recipe.servings)
    }
}

enum MealType: String, Codable, CaseIterable {
    case breakfast
    case lunch
    case dinner
    case snack
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var emoji: String {
        switch self {
        case .breakfast: return "🌅"
        case .lunch: return "🌞"
        case .dinner: return "🌙"
        case .snack: return "🍪"
        }
    }
}
