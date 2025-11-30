//
//  RecipeService.swift
//  MealPrepVisionTracker
//
//  Created on 11/26/2025.
//

import Foundation

class RecipeService {
    
    static let shared = RecipeService()
    
    private var allRecipes: [Recipe] = []
    
    private init() {
        loadSampleRecipes()
    }
    
    // MARK: - Recipe Matching
    
    func findMatchingRecipes(for ingredients: [Ingredient], limit: Int = 10) -> [Recipe] {
        let ingredientNames = Set(ingredients.map { $0.name.lowercased() })
        
        var scoredRecipes: [(recipe: Recipe, score: Double)] = []
        
        for var recipe in allRecipes {
            let requiredNames = Set(recipe.requiredIngredients.map { $0.name.lowercased() })
            let optionalNames = Set(recipe.optionalIngredients.map { $0.name.lowercased() })
            
            // Calculate match percentage
            let requiredMatches = ingredientNames.intersection(requiredNames).count
            let requiredTotal = requiredNames.count
            
            guard requiredTotal > 0 else { continue }
            
            let requiredScore = Double(requiredMatches) / Double(requiredTotal)
            
            // Bonus points for optional ingredients
            let optionalMatches = ingredientNames.intersection(optionalNames).count
            let optionalScore = optionalNames.isEmpty ? 0 : Double(optionalMatches) / Double(optionalNames.count) * 0.2
            
            let totalScore = (requiredScore * 0.8) + optionalScore
            
            // Only include recipes with at least 50% required ingredients
            if requiredScore >= 0.5 {
                recipe.matchPercentage = totalScore * 100
                scoredRecipes.append((recipe: recipe, score: totalScore))
            }
        }
        
        // Sort by score descending
        scoredRecipes.sort { $0.score > $1.score }
        
        return scoredRecipes.prefix(limit).map { $0.recipe }
    }
    
    // MARK: - Recipe CRUD
    
    func addRecipe(_ recipe: Recipe) {
        allRecipes.append(recipe)
        saveRecipes()
    }
    
    func removeRecipe(withId id: UUID) {
        allRecipes.removeAll { $0.id == id }
        saveRecipes()
    }
    
    func updateRecipe(_ recipe: Recipe) {
        if let index = allRecipes.firstIndex(where: { $0.id == recipe.id }) {
            allRecipes[index] = recipe
            saveRecipes()
        }
    }
    
    func getAllRecipes() -> [Recipe] {
        return allRecipes
    }
    
    func getRecipe(byId id: UUID) -> Recipe? {
        return allRecipes.first { $0.id == id }
    }
    
    // MARK: - Persistence
    
    private func saveRecipes() {
        if let encoded = try? JSONEncoder().encode(allRecipes) {
            UserDefaults.standard.set(encoded, forKey: "SavedRecipes")
        }
    }
    
    private func loadRecipes() {
        if let data = UserDefaults.standard.data(forKey: "SavedRecipes"),
           let decoded = try? JSONDecoder().decode([Recipe].self, from: data) {
            allRecipes = decoded
        }
    }
    
    // MARK: - Sample Data
    
    private func loadSampleRecipes() {
        allRecipes = [
            Recipe(
                name: "Quick Chicken Stir-Fry",
                description: "A fast and healthy dinner perfect for busy families",
                requiredIngredients: [
                    RecipeIngredient(name: "Chicken Breast", quantity: 1, unit: .pound),
                    RecipeIngredient(name: "Broccoli", quantity: 2, unit: .cup),
                    RecipeIngredient(name: "Carrot", quantity: 2, unit: .item),
                    RecipeIngredient(name: "Soy Sauce", quantity: 3, unit: .tablespoon)
                ],
                optionalIngredients: [
                    RecipeIngredient(name: "Ginger", quantity: 1, unit: .teaspoon),
                    RecipeIngredient(name: "Garlic", quantity: 2, unit: .item)
                ],
                instructions: [
                    "Cut chicken into bite-sized pieces",
                    "Chop vegetables into uniform pieces",
                    "Heat oil in wok or large pan over high heat",
                    "Cook chicken until browned, about 5 minutes",
                    "Add vegetables and stir-fry for 3-4 minutes",
                    "Add soy sauce and cook for 1 more minute",
                    "Serve immediately over rice"
                ],
                prepTime: 10,
                cookTime: 15,
                servings: 4,
                difficulty: .easy,
                nutritionalInfo: NutritionalInfo(
                    calories: 285,
                    protein: 35,
                    carbohydrates: 15,
                    fat: 8,
                    fiber: 4,
                    sugar: 5,
                    sodium: 650,
                    cholesterol: 85
                ),
                tags: ["quick", "healthy", "dinner", "asian"]
            ),
            Recipe(
                name: "Simple Pasta with Tomato Sauce",
                description: "Classic comfort food that kids love",
                requiredIngredients: [
                    RecipeIngredient(name: "Pasta", quantity: 1, unit: .pound),
                    RecipeIngredient(name: "Tomato", quantity: 5, unit: .item),
                    RecipeIngredient(name: "Onion", quantity: 1, unit: .item),
                    RecipeIngredient(name: "Garlic", quantity: 3, unit: .item)
                ],
                optionalIngredients: [
                    RecipeIngredient(name: "Basil", quantity: 10, unit: .item),
                    RecipeIngredient(name: "Parmesan Cheese", quantity: 0.5, unit: .cup)
                ],
                instructions: [
                    "Boil water for pasta with salt",
                    "Dice onions and mince garlic",
                    "Sauté onions until translucent",
                    "Add garlic and cook for 30 seconds",
                    "Add chopped tomatoes and simmer for 20 minutes",
                    "Cook pasta according to package directions",
                    "Drain pasta and toss with sauce",
                    "Top with fresh basil and cheese"
                ],
                prepTime: 10,
                cookTime: 25,
                servings: 4,
                difficulty: .easy,
                nutritionalInfo: NutritionalInfo(
                    calories: 380,
                    protein: 12,
                    carbohydrates: 65,
                    fat: 6,
                    fiber: 5,
                    sugar: 8,
                    sodium: 420,
                    cholesterol: 5
                ),
                tags: ["pasta", "italian", "vegetarian", "kid-friendly"]
            ),
            Recipe(
                name: "Breakfast Scramble",
                description: "Protein-packed breakfast to start your day",
                requiredIngredients: [
                    RecipeIngredient(name: "Egg", quantity: 6, unit: .item),
                    RecipeIngredient(name: "Milk", quantity: 0.25, unit: .cup),
                    RecipeIngredient(name: "Cheese", quantity: 0.5, unit: .cup)
                ],
                optionalIngredients: [
                    RecipeIngredient(name: "Spinach", quantity: 1, unit: .cup),
                    RecipeIngredient(name: "Tomato", quantity: 1, unit: .item),
                    RecipeIngredient(name: "Onion", quantity: 0.5, unit: .item)
                ],
                instructions: [
                    "Whisk eggs with milk and a pinch of salt",
                    "Heat butter in non-stick pan",
                    "Pour in egg mixture",
                    "Gently scramble eggs until just set",
                    "Add cheese and fold in",
                    "Remove from heat while still slightly creamy"
                ],
                prepTime: 5,
                cookTime: 5,
                servings: 3,
                difficulty: .easy,
                nutritionalInfo: NutritionalInfo(
                    calories: 245,
                    protein: 18,
                    carbohydrates: 3,
                    fat: 18,
                    fiber: 0,
                    sugar: 2,
                    sodium: 380,
                    cholesterol: 425
                ),
                tags: ["breakfast", "quick", "protein", "vegetarian"]
            )
        ]
    }
}
