//
//  NutritionInteractor.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import Foundation

protocol NutritionRouting: ViewableRouting {
}

protocol NutritionPresentable: Presentable {
    func displayMealPlans(_ mealPlans: [MealPlan], for date: Date)
}

protocol NutritionListener: AnyObject {
}

final class NutritionInteractor: Interactor, NutritionPresentableListener {
    
    weak var router: NutritionRouting?
    weak var listener: NutritionListener?
    
    private let presenter: NutritionPresentable
    private let persistenceManager: PersistenceManager
    
    init(
        presenter: NutritionPresentable,
        persistenceManager: PersistenceManager
    ) {
        self.presenter = presenter
        self.persistenceManager = persistenceManager
        super.init()
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        loadMealPlans(for: Date())
    }
    
    // MARK: - NutritionPresentableListener
    
    func viewDidAppear() {
        loadMealPlans(for: Date())
    }
    
    func didChangeDate(_ date: Date) {
        loadMealPlans(for: date)
    }
    
    // MARK: - Private
    
    private func loadMealPlans(for date: Date) {
        let mealPlans = persistenceManager.getMealPlans(for: date)
        presenter.displayMealPlans(mealPlans, for: date)
    }
}
