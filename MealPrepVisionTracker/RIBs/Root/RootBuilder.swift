//
//  RootBuilder.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import UIKit

protocol RootDependency: Dependency {
    var visionService: VisionService { get }
    var recipeService: RecipeService { get }
    var persistenceManager: PersistenceManager { get }
}

final class RootComponent: Component<RootDependency>, CameraDependency, IngredientsDependency, RecipesDependency, NutritionDependency {
    var visionService: VisionService {
        return dependency.visionService
    }
    
    var recipeService: RecipeService {
        return dependency.recipeService
    }
    
    var persistenceManager: PersistenceManager {
        return dependency.persistenceManager
    }
}

// MARK: - Builder

protocol RootBuildable: Buildable {
    func build() -> LaunchRouting
}

final class RootBuilder: RootBuildable {
    
    private let dependency: RootDependency
    
    init(dependency: RootDependency) {
        self.dependency = dependency
    }
    
    func build() -> LaunchRouting {
        let component = RootComponent(dependency: dependency)
        let interactor = RootInteractor()
        
        let cameraBuilder = CameraBuilder(dependency: component)
        let ingredientsBuilder = IngredientsBuilder(dependency: component)
        let recipesBuilder = RecipesBuilder(dependency: component)
        let nutritionBuilder = NutritionBuilder(dependency: component)
        
        let router = RootRouter(
            interactor: interactor,
            cameraBuilder: cameraBuilder,
            ingredientsBuilder: ingredientsBuilder,
            recipesBuilder: recipesBuilder,
            nutritionBuilder: nutritionBuilder
        )
        
        interactor.router = router
        return router
    }
}
