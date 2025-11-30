//
//  CameraInteractor.swift
//  MealPrepVisionTracker
//
//  Created on 11/27/2025.
//

import UIKit

protocol CameraRouting: ViewableRouting {
    func routeToIngredientResult(ingredients: [Ingredient], image: UIImage)
    func dismissIngredientResult()
}

protocol CameraPresentable: Presentable {
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
}

protocol CameraPresentableListener: PresentableListener {
    func didCaptureImage(_ image: UIImage)
}

protocol CameraListener: AnyObject {
    // Parent can listen to Camera events here
}

final class CameraInteractor: Interactor, CameraPresentableListener, IngredientResultListener {
    
    weak var router: CameraRouting?
    weak var listener: CameraListener?
    
    private let presenter: CameraPresentable
    private let visionService: VisionService
    private let persistenceManager: PersistenceManager
    
    init(
        presenter: CameraPresentable,
        visionService: VisionService,
        persistenceManager: PersistenceManager
    ) {
        self.presenter = presenter
        self.visionService = visionService
        self.persistenceManager = persistenceManager
        super.init()
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
    }
    
    // MARK: - CameraPresentableListener
    
    func didCaptureImage(_ image: UIImage) {
        presenter.showLoading()
        
        visionService.recognizeIngredients(from: image) { [weak self] result in
            guard let self = self else { return }
            
            self.presenter.hideLoading()
            
            switch result {
            case .success(let ingredients):
                if ingredients.isEmpty {
                    self.presenter.showError("No ingredients detected. Try a clearer photo.")
                } else {
                    self.router?.routeToIngredientResult(ingredients: ingredients, image: image)
                }
            case .failure(let error):
                self.presenter.showError(error.localizedDescription)
            }
        }
    }
    
    func didDismissIngredientResult() {
        router?.dismissIngredientResult()
    }
}
