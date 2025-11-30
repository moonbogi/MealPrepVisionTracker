//
//  RootRouter.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import UIKit

final class RootRouter: Router<RootInteractor>, RootRouting, LaunchRouting {
    
    private let cameraBuilder: CameraBuildable
    private let ingredientsBuilder: IngredientsBuildable
    private let recipesBuilder: RecipesBuildable
    private let nutritionBuilder: NutritionBuildable
    
    private var tabBarController: UITabBarController?
    
    private var cameraRouter: ViewableRouting?
    private var ingredientsRouter: ViewableRouting?
    private var recipesRouter: ViewableRouting?
    private var nutritionRouter: ViewableRouting?
    
    init(
        interactor: RootInteractor,
        cameraBuilder: CameraBuildable,
        ingredientsBuilder: IngredientsBuildable,
        recipesBuilder: RecipesBuildable,
        nutritionBuilder: NutritionBuildable
    ) {
        self.cameraBuilder = cameraBuilder
        self.ingredientsBuilder = ingredientsBuilder
        self.recipesBuilder = recipesBuilder
        self.nutritionBuilder = nutritionBuilder
        super.init(interactor: interactor)
    }
    
    // MARK: - LaunchRouting
    
    func launch(from window: UIWindow) {
        let tabBar = UITabBarController()
        setupTabBarAppearance(tabBar)
        tabBarController = tabBar
        
        // Check if onboarding has been completed
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if hasCompletedOnboarding {
            window.rootViewController = tabBar
        } else {
            let onboarding = OnboardingViewController()
            onboarding.onComplete = { [weak self, weak window] in
                UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    window?.rootViewController = tabBar
                })
                self?.interactor.activate()
            }
            window.rootViewController = onboarding
        }
        
        window.makeKeyAndVisible()
        
        if hasCompletedOnboarding {
            interactor.activate()
        }
    }
    
    // MARK: - RootRouting
    
    func routeToMain() {
        guard let tabBar = tabBarController else { return }
        
        // Build all feature RIBs
        let cameraRouter = cameraBuilder.build(withListener: interactor)
        let ingredientsRouter = ingredientsBuilder.build(withListener: interactor)
        let recipesRouter = recipesBuilder.build(withListener: interactor)
        let nutritionRouter = nutritionBuilder.build(withListener: interactor)
        
        self.cameraRouter = cameraRouter
        self.ingredientsRouter = ingredientsRouter
        self.recipesRouter = recipesRouter
        self.nutritionRouter = nutritionRouter
        
        attachChild(cameraRouter)
        attachChild(ingredientsRouter)
        attachChild(recipesRouter)
        attachChild(nutritionRouter)
        
        // Setup navigation controllers
        let cameraNav = createNavController(
            for: cameraRouter.viewControllable.uiviewController,
            title: "Scan",
            image: "camera.fill"
        )
        
        let ingredientsNav = createNavController(
            for: ingredientsRouter.viewControllable.uiviewController,
            title: "Pantry",
            image: "basket.fill"
        )
        
        let recipesNav = createNavController(
            for: recipesRouter.viewControllable.uiviewController,
            title: "Recipes",
            image: "book.fill"
        )
        
        let nutritionNav = createNavController(
            for: nutritionRouter.viewControllable.uiviewController,
            title: "Nutrition",
            image: "chart.bar.fill"
        )
        
        tabBar.setViewControllers([cameraNav, ingredientsNav, recipesNav, nutritionNav], animated: false)
    }
    
    // MARK: - Private Helpers
    
    private func createNavController(for viewController: UIViewController, title: String, image: String) -> UINavigationController {
        let nav = UINavigationController(rootViewController: viewController)
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            tag: 0
        )
        return nav
    }
    
    private func setupTabBarAppearance(_ tabBar: UITabBarController) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        tabBar.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.tabBar.tintColor = .systemGreen
    }
}

// MARK: - Camera/Ingredients/Recipes/Nutrition Listener

extension RootInteractor: CameraListener, IngredientsListener, RecipesListener, NutritionListener {
    // Implement cross-feature communication here if needed
}
