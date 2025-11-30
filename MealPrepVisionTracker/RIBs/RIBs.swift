//
//  RIBs.swift
//  MealPrepVisionTracker
//
//  RIBs Architecture Base Protocols and Classes
//  Created on 11/27/2025.
//

import UIKit

// MARK: - Routing

/// Base protocol for all Routers
protocol Routing: AnyObject {
    func cleanupViews()
}

extension Routing {
    func cleanupViews() {
        // Default implementation
    }
}

/// Base protocol for view-less Routers
protocol ViewlessRouting: Routing {
}

/// Base protocol for Routers that own a ViewController
protocol ViewableRouting: Routing {
    var viewControllable: ViewControllable { get }
}

// MARK: - View Controllable

/// Abstraction for UIViewController to make it testable
protocol ViewControllable: AnyObject {
    var uiviewController: UIViewController { get }
}

extension UIViewController: ViewControllable {
    var uiviewController: UIViewController {
        return self
    }
}

// MARK: - Interactor

/// Base class for all Interactors
class Interactor {
    var isActive: Bool = false
    
    func activate() {
        guard !isActive else { return }
        isActive = true
        didBecomeActive()
    }
    
    func deactivate() {
        guard isActive else { return }
        isActive = false
        willResignActive()
    }
    
    /// Called when interactor becomes active
    func didBecomeActive() {
        // Override in subclass
    }
    
    /// Called when interactor is about to resign active
    func willResignActive() {
        // Override in subclass
    }
}

/// Interactor that can be presented
protocol PresentableInteractor: AnyObject {
    var listener: InteractorListener? { get set }
}

/// Base listener for interactors
protocol InteractorListener: AnyObject {
}

// MARK: - Presentable

/// Protocol for presentable logic
protocol Presentable: AnyObject {
    var listener: PresentableListener? { get set }
}

/// Base listener for presenters
protocol PresentableListener: AnyObject {
}

// MARK: - Router

/// Base Router class
class Router<InteractorType>: Routing {
    let interactor: InteractorType
    
    private var children: [Routing] = []
    
    init(interactor: InteractorType) {
        self.interactor = interactor
    }
    
    // MARK: - Child Management
    
    func attachChild(_ child: Routing) {
        children.append(child)
    }
    
    func detachChild(_ child: Routing) {
        children.removeAll { $0 === child }
        child.cleanupViews()
    }
    
    func cleanupViews() {
        children.forEach { $0.cleanupViews() }
        children.removeAll()
    }
}

/// Base ViewableRouter class
class ViewableRouter<InteractorType, ViewControllerType>: Router<InteractorType>, ViewableRouting where ViewControllerType: ViewControllable {
    
    let viewController: ViewControllerType
    
    var viewControllable: ViewControllable {
        return viewController
    }
    
    init(interactor: InteractorType, viewController: ViewControllerType) {
        self.viewController = viewController
        super.init(interactor: interactor)
    }
}

// MARK: - Builder

/// Base protocol for all Builders
protocol Buildable: AnyObject {
}

/// Dependency protocol for builders
protocol Dependency {
}

// MARK: - Component

/// Base component for dependency management
class Component<DependencyType>: Dependency {
    let dependency: DependencyType
    
    init(dependency: DependencyType) {
        self.dependency = dependency
    }
}

// MARK: - LaunchRouting

/// Protocol for the root router that launches the app
protocol LaunchRouting: Routing {
    func launch(from window: UIWindow)
}
