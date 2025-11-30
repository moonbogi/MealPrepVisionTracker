//
//  Ingredient.swift
//  MealPrepVisionTracker
//
//  Created on 11/26/2025.
//

import Foundation

struct Ingredient: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: IngredientCategory
    let quantity: Double
    let unit: MeasurementUnit
    let dateAdded: Date
    let expirationDate: Date?
    let imageData: Data?
    let confidence: Float // Confidence score from Vision framework
    
    init(
        id: UUID = UUID(),
        name: String,
        category: IngredientCategory,
        quantity: Double = 1.0,
        unit: MeasurementUnit = .item,
        dateAdded: Date = Date(),
        expirationDate: Date? = nil,
        imageData: Data? = nil,
        confidence: Float = 1.0
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.dateAdded = dateAdded
        self.expirationDate = expirationDate
        self.imageData = imageData
        self.confidence = confidence
    }
}

enum IngredientCategory: String, Codable, CaseIterable {
    case vegetable
    case fruit
    case protein
    case dairy
    case grain
    case spice
    case condiment
    case other
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var emoji: String {
        switch self {
        case .vegetable: return "🥦"
        case .fruit: return "🍎"
        case .protein: return "🍗"
        case .dairy: return "🥛"
        case .grain: return "🌾"
        case .spice: return "🌶️"
        case .condiment: return "🧂"
        case .other: return "📦"
        }
    }
}

enum MeasurementUnit: String, Codable, CaseIterable {
    case item
    case gram
    case kilogram
    case ounce
    case pound
    case cup
    case tablespoon
    case teaspoon
    case milliliter
    case liter
    
    var abbreviation: String {
        switch self {
        case .item: return "item"
        case .gram: return "g"
        case .kilogram: return "kg"
        case .ounce: return "oz"
        case .pound: return "lb"
        case .cup: return "cup"
        case .tablespoon: return "tbsp"
        case .teaspoon: return "tsp"
        case .milliliter: return "ml"
        case .liter: return "L"
        }
    }
}
