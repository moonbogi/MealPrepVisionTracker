//
//  MainTabBarController.swift
//  MealPrepVisionTracker
//
//  Created on 11/26/2025.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    private func setupViewControllers() {
        // Camera/Scan Tab
        let cameraVC = CameraViewController()
        let cameraNav = UINavigationController(rootViewController: cameraVC)
        cameraNav.tabBarItem = UITabBarItem(
            title: "Scan",
            image: UIImage(systemName: "camera.fill"),
            tag: 0
        )
        
        // Ingredients Tab
        let ingredientsVC = IngredientsViewController()
        let ingredientsNav = UINavigationController(rootViewController: ingredientsVC)
        ingredientsNav.tabBarItem = UITabBarItem(
            title: "Pantry",
            image: UIImage(systemName: "basket.fill"),
            tag: 1
        )
        
        // Recipes Tab
        let recipesVC = RecipesViewController()
        let recipesNav = UINavigationController(rootViewController: recipesVC)
        recipesNav.tabBarItem = UITabBarItem(
            title: "Recipes",
            image: UIImage(systemName: "book.fill"),
            tag: 2
        )
        
        // Nutrition Tab
        let nutritionVC = NutritionViewController()
        let nutritionNav = UINavigationController(rootViewController: nutritionVC)
        nutritionNav.tabBarItem = UITabBarItem(
            title: "Nutrition",
            image: UIImage(systemName: "chart.bar.fill"),
            tag: 3
        )
        
        viewControllers = [cameraNav, ingredientsNav, recipesNav, nutritionNav]
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.tintColor = .systemGreen
    }
}
