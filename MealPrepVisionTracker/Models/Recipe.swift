//
//  Recipe.swift
//  MealPrepVisionTracker
//
//  Created on 11/26/2025.
//

import Foundation

struct Recipe: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let requiredIngredients: [RecipeIngredient]
    let optionalIngredients: [RecipeIngredient]
    let instructions: [String]
    let prepTime: Int // minutes
    let cookTime: Int // minutes
    let servings: Int
    let difficulty: DifficultyLevel
    let nutritionalInfo: NutritionalInfo
    let imageURL: String?
    let tags: [String]
    
    // Calculated property for matching score
    var matchPercentage: Double = 0.0
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        requiredIngredients: [RecipeIngredient],
        optionalIngredients: [RecipeIngredient] = [],
        instructions: [String],
        prepTime: Int,
        cookTime: Int,
        servings: Int,
        difficulty: DifficultyLevel,
        nutritionalInfo: NutritionalInfo,
        imageURL: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.requiredIngredients = requiredIngredients
        self.optionalIngredients = optionalIngredients
        self.instructions = instructions
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.difficulty = difficulty
        self.nutritionalInfo = nutritionalInfo
        self.imageURL = imageURL
        self.tags = tags
    }
}

struct RecipeIngredient: Codable, Hashable {
    let name: String
    let quantity: Double
    let unit: MeasurementUnit
    let notes: String?
    
    init(name: String, quantity: Double, unit: MeasurementUnit, notes: String? = nil) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.notes = notes
    }
}

enum DifficultyLevel: String, Codable, CaseIterable {
    case easy
    case medium
    case hard
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var emoji: String {
        switch self {
        case .easy: return "😊"
        case .medium: return "🤔"
        case .hard: return "😰"
        }
    }
}
