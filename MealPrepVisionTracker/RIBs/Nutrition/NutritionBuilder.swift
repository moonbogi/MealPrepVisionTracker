//
//  NutritionBuilder.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import Foundation

protocol NutritionDependency: Dependency {
    var persistenceManager: PersistenceManager { get }
}

final class NutritionComponent: Component<NutritionDependency> {
    var persistenceManager: PersistenceManager {
        return dependency.persistenceManager
    }
}

// MARK: - Builder

protocol NutritionBuildable: Buildable {
    func build(withListener listener: NutritionListener) -> ViewableRouting
}

final class NutritionBuilder: NutritionBuildable {
    
    private let dependency: NutritionDependency
    
    init(dependency: NutritionDependency) {
        self.dependency = dependency
    }
    
    func build(withListener listener: NutritionListener) -> ViewableRouting {
        let component = NutritionComponent(dependency: dependency)
        let viewController = NutritionViewController()
        let interactor = NutritionInteractor(
            presenter: viewController,
            persistenceManager: component.persistenceManager
        )
        interactor.listener = listener
        viewController.listener = interactor
        
        let router = NutritionRouter(interactor: interactor, viewController: viewController)
        interactor.router = router
        
        return router
    }
}
