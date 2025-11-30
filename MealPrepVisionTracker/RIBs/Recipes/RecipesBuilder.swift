//
//  RecipesBuilder.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import Foundation

protocol RecipesDependency: Dependency {
    var recipeService: RecipeService { get }
    var persistenceManager: PersistenceManager { get }
}

final class RecipesComponent: Component<RecipesDependency> {
    var recipeService: RecipeService {
        return dependency.recipeService
    }
    
    var persistenceManager: PersistenceManager {
        return dependency.persistenceManager
    }
}

// MARK: - Builder

protocol RecipesBuildable: Buildable {
    func build(withListener listener: RecipesListener) -> ViewableRouting
}

final class RecipesBuilder: RecipesBuildable {
    
    private let dependency: RecipesDependency
    
    init(dependency: RecipesDependency) {
        self.dependency = dependency
    }
    
    func build(withListener listener: RecipesListener) -> ViewableRouting {
        let component = RecipesComponent(dependency: dependency)
        let viewController = RecipesViewController()
        let interactor = RecipesInteractor(
            presenter: viewController,
            recipeService: component.recipeService,
            persistenceManager: component.persistenceManager
        )
        interactor.listener = listener
        viewController.listener = interactor
        
        let router = RecipesRouter(interactor: interactor, viewController: viewController)
        interactor.router = router
        
        return router
    }
}
