//
//  CoreDataManager.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MealPrepModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Core Data error: \(error), \(error.userInfo)")
                // In production, handle this more gracefully
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    // MARK: - Ingredient Operations
    
    func saveIngredient(_ ingredient: Ingredient) {
        let entity = NSEntityDescription.entity(forEntityName: "IngredientEntity", in: context)!
        let ingredientEntity = NSManagedObject(entity: entity, insertInto: context)
        
        ingredientEntity.setValue(ingredient.id, forKey: "id")
        ingredientEntity.setValue(ingredient.name, forKey: "name")
        ingredientEntity.setValue(ingredient.category.rawValue, forKey: "category")
        ingredientEntity.setValue(ingredient.quantity, forKey: "quantity")
        ingredientEntity.setValue(ingredient.unit.rawValue, forKey: "unit")
        ingredientEntity.setValue(ingredient.imageData, forKey: "imageData")
        ingredientEntity.setValue(ingredient.confidence, forKey: "confidence")
        ingredientEntity.setValue(Date(), forKey: "dateAdded")
        
        saveContext()
    }
    
    func fetchIngredients() -> [Ingredient] {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "IngredientEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { convertToIngredient($0) }
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    func deleteIngredient(_ ingredient: Ingredient) {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "IngredientEntity")
        request.predicate = NSPredicate(format: "id == %@", ingredient.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            saveContext()
        } catch {
            print("Delete error: \(error)")
        }
    }
    
    // MARK: - Meal Plan Operations
    
    func saveMealPlan(_ mealPlan: MealPlan) {
        let entity = NSEntityDescription.entity(forEntityName: "MealPlanEntity", in: context)!
        let mealPlanEntity = NSManagedObject(entity: entity, insertInto: context)
        
        mealPlanEntity.setValue(mealPlan.id, forKey: "id")
        mealPlanEntity.setValue(mealPlan.date, forKey: "date")
        mealPlanEntity.setValue(mealPlan.mealType.rawValue, forKey: "mealType")
        
        // Convert single recipe to JSON data
        if let recipeData = try? JSONEncoder().encode(mealPlan.recipe) {
            mealPlanEntity.setValue(recipeData, forKey: "recipesData")
        }
        
        saveContext()
    }
    
    func fetchMealPlans(for date: Date) -> [MealPlan] {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "MealPlanEntity")
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as CVarArg, endDate as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "mealType", ascending: true)]
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { convertToMealPlan($0) }
        } catch {
            print("Fetch meal plans error: \(error)")
            return []
        }
    }
    
    // MARK: - Helper Methods
    
    private func convertToIngredient(_ managedObject: NSManagedObject) -> Ingredient? {
        guard let id = managedObject.value(forKey: "id") as? UUID,
              let name = managedObject.value(forKey: "name") as? String,
              let categoryRaw = managedObject.value(forKey: "category") as? String,
              let category = IngredientCategory(rawValue: categoryRaw),
              let quantity = managedObject.value(forKey: "quantity") as? Double,
              let unitRaw = managedObject.value(forKey: "unit") as? String,
              let unit = MeasurementUnit(rawValue: unitRaw) else {
            return nil
        }
        
        let imageData = managedObject.value(forKey: "imageData") as? Data
        let confidence = managedObject.value(forKey: "confidence") as? Float ?? 0.0
        
        return Ingredient(
            id: id,
            name: name,
            category: category,
            quantity: quantity,
            unit: unit,
            imageData: imageData,
            confidence: confidence
        )
    }
    
    private func convertToMealPlan(_ managedObject: NSManagedObject) -> MealPlan? {
        guard let id = managedObject.value(forKey: "id") as? UUID,
              let date = managedObject.value(forKey: "date") as? Date,
              let mealTypeRaw = managedObject.value(forKey: "mealType") as? String,
              let mealType = MealType(rawValue: mealTypeRaw),
              let recipeData = managedObject.value(forKey: "recipesData") as? Data,
              let recipe = try? JSONDecoder().decode(Recipe.self, from: recipeData) else {
            return nil
        }
        
        return MealPlan(id: id, date: date, mealType: mealType, recipe: recipe)
    }
}