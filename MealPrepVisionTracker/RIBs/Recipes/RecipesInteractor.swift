//
//  RecipesInteractor.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import Foundation

protocol RecipesRouting: ViewableRouting {
    func routeToRecipeDetail(_ recipe: Recipe)
}

protocol RecipesPresentable: Presentable {
    func displayRecipes(matched: [Recipe], all: [Recipe])
}

protocol RecipesListener: AnyObject {
}

final class RecipesInteractor: Interactor, RecipesPresentableListener {
    
    weak var router: RecipesRouting?
    weak var listener: RecipesListener?
    
    private let presenter: RecipesPresentable
    private let recipeService: RecipeService
    private let persistenceManager: PersistenceManager
    
    init(
        presenter: RecipesPresentable,
        recipeService: RecipeService,
        persistenceManager: PersistenceManager
    ) {
        self.presenter = presenter
        self.recipeService = recipeService
        self.persistenceManager = persistenceManager
        super.init()
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        loadRecipes()
    }
    
    // MARK: - RecipesPresentableListener
    
    func viewDidAppear() {
        loadRecipes()
    }
    
    func didSelectRecipe(_ recipe: Recipe) {
        router?.routeToRecipeDetail(recipe)
    }
    
    // MARK: - Private
    
    private func loadRecipes() {
        let ingredients = persistenceManager.loadIngredients()
        let allRecipes = recipeService.getAllRecipes()
        let matchedRecipes = recipeService.findMatchingRecipes(for: ingredients)
        
        presenter.displayRecipes(matched: matchedRecipes, all: allRecipes)
    }
}
