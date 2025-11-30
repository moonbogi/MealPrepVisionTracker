//
//  CameraRouter.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import UIKit

final class CameraRouter: ViewableRouter<CameraInteractor, CameraViewController>, CameraRouting {
    
    private var ingredientResultViewController: IngredientResultViewController?
    
    // MARK: - CameraRouting
    
    func routeToIngredientResult(ingredients: [Ingredient], image: UIImage) {
        let resultVC = IngredientResultViewController(
            ingredients: ingredients,
            image: image,
            listener: interactor
        )
        ingredientResultViewController = resultVC
        viewController.uiviewController.navigationController?.pushViewController(resultVC, animated: true)
    }
    
    func dismissIngredientResult() {
        guard ingredientResultViewController != nil else { return }
        viewController.uiviewController.navigationController?.popViewController(animated: true)
        ingredientResultViewController = nil
    }
}
