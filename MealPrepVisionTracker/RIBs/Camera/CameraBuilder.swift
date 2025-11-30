//
//  CameraBuilder.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import Foundation

protocol CameraDependency: Dependency {
    var visionService: VisionService { get }
    var persistenceManager: PersistenceManager { get }
}

final class CameraComponent: Component<CameraDependency> {
    var visionService: VisionService {
        return dependency.visionService
    }
    
    var persistenceManager: PersistenceManager {
        return dependency.persistenceManager
    }
}

// MARK: - Builder

protocol CameraBuildable: Buildable {
    func build(withListener listener: CameraListener) -> ViewableRouting
}

final class CameraBuilder: CameraBuildable {
    
    private let dependency: CameraDependency
    
    init(dependency: CameraDependency) {
        self.dependency = dependency
    }
    
    func build(withListener listener: CameraListener) -> ViewableRouting {
        let component = CameraComponent(dependency: dependency)
        let viewController = CameraViewController()
        let interactor = CameraInteractor(
            presenter: viewController,
            visionService: component.visionService,
            persistenceManager: component.persistenceManager
        )
        interactor.listener = listener
        viewController.listener = interactor
        
        let router = CameraRouter(interactor: interactor, viewController: viewController)
        interactor.router = router
        
        return router
    }
}
