//
//  RootInteractor.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import Foundation

protocol RootRouting: Routing {
    func routeToMain()
}

final class RootInteractor: Interactor {
    
    weak var router: RootRouting?
    
    override func didBecomeActive() {
        super.didBecomeActive()
        router?.routeToMain()
    }
}
