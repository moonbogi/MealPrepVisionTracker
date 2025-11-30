//
//  PersistenceManager.swift
//  MealPrepVisionTracker
//
//  Created on 11/26/2025.
//

import Foundation

class PersistenceManager {
    
    static let shared = PersistenceManager()
    
    private let coreDataManager = CoreDataManager.shared
    
    // Legacy UserDefaults keys for backward compatibility
    private let ingredientsKey = "SavedIngredients"
    private let mealPlansKey = "SavedMealPlans"
    
    private init() {}
    
    // MARK: - Ingredients Persistence
    
    func saveIngredients(_ ingredients: [Ingredient]) {
        // Save each ingredient individually with CoreData
        for ingredient in ingredients {
            addIngredient(ingredient)
        }
    }
    
    func loadIngredients() -> [Ingredient] {
        return coreDataManager.fetchIngredients()
    }
    
    func addIngredient(_ ingredient: Ingredient) {
        guard !ingredient.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("Warning: Attempted to add ingredient with empty name")
            return
        }
        
        let existingIngredients = coreDataManager.fetchIngredients()
        
        // Check for duplicates by name
        if existingIngredients.contains(where: { $0.name.lowercased() == ingredient.name.lowercased() }) {
            print("Warning: Ingredient '\(ingredient.name)' already exists")
            return
        }
        
        coreDataManager.saveIngredient(ingredient)
    }
    
    func removeIngredient(withId id: UUID) {
        let ingredients = coreDataManager.fetchIngredients()
        if let ingredient = ingredients.first(where: { $0.id == id }) {
            coreDataManager.deleteIngredient(ingredient)
        }
    }
    
    func updateIngredient(_ ingredient: Ingredient) {
        // Delete old version and save new one
        removeIngredient(withId: ingredient.id)
        coreDataManager.saveIngredient(ingredient)
    }
    
    // MARK: - Meal Plans Persistence
    
    func saveMealPlans(_ mealPlans: [MealPlan]) {
        if let encoded = try? JSONEncoder().encode(mealPlans) {
            UserDefaults.standard.set(encoded, forKey: mealPlansKey)
        }
    }
    
    func loadMealPlans() -> [MealPlan] {
        guard let data = UserDefaults.standard.data(forKey: mealPlansKey),
              let decoded = try? JSONDecoder().decode([MealPlan].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func addMealPlan(_ mealPlan: MealPlan) {
        var mealPlans = loadMealPlans()
        mealPlans.append(mealPlan)
        saveMealPlans(mealPlans)
    }
    
    func removeMealPlan(withId id: UUID) {
        var mealPlans = loadMealPlans()
        mealPlans.removeAll { $0.id == id }
        saveMealPlans(mealPlans)
    }
    
    func getMealPlans(for date: Date) -> [MealPlan] {
        let mealPlans = loadMealPlans()
        let calendar = Calendar.current
        return mealPlans.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    // MARK: - Clear All Data
    
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: ingredientsKey)
        UserDefaults.standard.removeObject(forKey: mealPlansKey)
    }
}
