//
//  SceneDelegate.swift
//  MealPrepVisionTracker
//
//  Created on 11/26/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var launchRouter: LaunchRouting?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create window programmatically
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Create app dependencies
        let appDependency = AppComponent()
        
        // Build and launch Root RIB
        let rootBuilder = RootBuilder(dependency: appDependency)
        let router = rootBuilder.build()
        self.launchRouter = router
        
        router.launch(from: window)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

// MARK: - App Component (Root Dependency)

final class AppComponent: RootDependency {
    var visionService: VisionService {
        return VisionService.shared
    }
    
    var recipeService: RecipeService {
        return RecipeService.shared
    }
    
    var persistenceManager: PersistenceManager {
        return PersistenceManager.shared
    }
}
