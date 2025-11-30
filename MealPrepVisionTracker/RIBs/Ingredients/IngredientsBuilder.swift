//
//  IngredientsBuilder.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import Foundation

protocol IngredientsDependency: Dependency {
    var persistenceManager: PersistenceManager { get }
}

final class IngredientsComponent: Component<IngredientsDependency> {
    var persistenceManager: PersistenceManager {
        return dependency.persistenceManager
    }
}

// MARK: - Builder

protocol IngredientsBuildable: Buildable {
    func build(withListener listener: IngredientsListener) -> ViewableRouting
}

final class IngredientsBuilder: IngredientsBuildable {
    
    private let dependency: IngredientsDependency
    
    init(dependency: IngredientsDependency) {
        self.dependency = dependency
    }
    
    func build(withListener listener: IngredientsListener) -> ViewableRouting {
        let component = IngredientsComponent(dependency: dependency)
        let viewController = IngredientsViewController()
        let interactor = IngredientsInteractor(
            presenter: viewController,
            persistenceManager: component.persistenceManager
        )
        interactor.listener = listener
        viewController.listener = interactor
        
        let router = IngredientsRouter(interactor: interactor, viewController: viewController)
        interactor.router = router
        
        return router
    }
}
