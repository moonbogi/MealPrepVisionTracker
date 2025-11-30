//
//  IngredientsInteractor.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import Foundation

protocol IngredientsRouting: ViewableRouting {
}

protocol IngredientsPresentable: Presentable {
    func displayIngredients(_ ingredients: [Ingredient])
}

protocol IngredientsListener: AnyObject {
}

final class IngredientsInteractor: Interactor, IngredientsPresentableListener {
    
    weak var router: IngredientsRouting?
    weak var listener: IngredientsListener?
    
    private let presenter: IngredientsPresentable
    private let persistenceManager: PersistenceManager
    
    init(
        presenter: IngredientsPresentable,
        persistenceManager: PersistenceManager
    ) {
        self.presenter = presenter
        self.persistenceManager = persistenceManager
        super.init()
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        loadIngredients()
    }
    
    // MARK: - IngredientsPresentableListener
    
    func viewDidAppear() {
        loadIngredients()
    }
    
    func didAddIngredient(name: String) {
        let ingredient = Ingredient(
            name: name,
            category: .other,
            quantity: 1.0,
            unit: .item
        )
        persistenceManager.addIngredient(ingredient)
        loadIngredients()
    }
    
    func didDeleteIngredient(_ ingredient: Ingredient) {
        persistenceManager.removeIngredient(withId: ingredient.id)
        loadIngredients()
    }
    
    // MARK: - Private
    
    private func loadIngredients() {
        let ingredients = persistenceManager.loadIngredients()
        presenter.displayIngredients(ingredients)
    }
}
