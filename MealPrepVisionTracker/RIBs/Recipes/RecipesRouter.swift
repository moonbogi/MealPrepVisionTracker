//
//  RecipesRouter.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import Foundation

final class RecipesRouter: ViewableRouter<RecipesInteractor, RecipesViewController>, RecipesRouting {
    
    func routeToRecipeDetail(_ recipe: Recipe) {
        let detailVC = RecipeDetailViewController(recipe: recipe)
        viewController.uiviewController.navigationController?.pushViewController(detailVC, animated: true)
    }
}
