//
//  RecipeDetailViewController.swift
//  MealPrepVisionTracker
//
//  Created on 11/26/2025.
//

import UIKit

class RecipeDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let recipe: Recipe
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Init
    
    init(recipe: Recipe) {
        self.recipe = recipe
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = recipe.name
        view.backgroundColor = .systemBackground
        
        setupUI()
        populateContent()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func populateContent() {
        // Header Info
        let headerView = createHeaderView()
        contentStack.addArrangedSubview(headerView)
        
        // Description
        let descLabel = createSectionLabel(recipe.description)
        contentStack.addArrangedSubview(descLabel)
        
        // Nutritional Info
        let nutritionView = createNutritionView()
        contentStack.addArrangedSubview(nutritionView)
        
        // Required Ingredients
        let reqHeader = createHeaderLabel("Required Ingredients")
        contentStack.addArrangedSubview(reqHeader)
        
        for ingredient in recipe.requiredIngredients {
            let label = createIngredientLabel("• \(ingredient.name) - \(ingredient.quantity) \(ingredient.unit.abbreviation)")
            contentStack.addArrangedSubview(label)
        }
        
        // Optional Ingredients
        if !recipe.optionalIngredients.isEmpty {
            let optHeader = createHeaderLabel("Optional Ingredients")
            contentStack.addArrangedSubview(optHeader)
            
            for ingredient in recipe.optionalIngredients {
                let label = createIngredientLabel("• \(ingredient.name) - \(ingredient.quantity) \(ingredient.unit.abbreviation)")
                label.textColor = .secondaryLabel
                contentStack.addArrangedSubview(label)
            }
        }
        
        // Instructions
        let instructionsHeader = createHeaderLabel("Instructions")
        contentStack.addArrangedSubview(instructionsHeader)
        
        for (index, instruction) in recipe.instructions.enumerated() {
            let label = createInstructionLabel("\(index + 1). \(instruction)")
            contentStack.addArrangedSubview(label)
        }
    }
    
    // MARK: - View Creation Helpers
    
    private func createHeaderView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let timeLabel = UILabel()
        timeLabel.text = "⏱ Prep: \(recipe.prepTime)min | Cook: \(recipe.cookTime)min"
        timeLabel.font = .systemFont(ofSize: 15)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let servingsLabel = UILabel()
        servingsLabel.text = "🍽 \(recipe.servings) servings"
        servingsLabel.font = .systemFont(ofSize: 15)
        servingsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let difficultyLabel = UILabel()
        difficultyLabel.text = "\(recipe.difficulty.emoji) \(recipe.difficulty.displayName)"
        difficultyLabel.font = .systemFont(ofSize: 15)
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(timeLabel)
        container.addSubview(servingsLabel)
        container.addSubview(difficultyLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: container.topAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            
            servingsLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            servingsLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            
            difficultyLabel.topAnchor.constraint(equalTo: servingsLabel.bottomAnchor, constant: 4),
            difficultyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            difficultyLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func createNutritionView() -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Nutrition (per serving)"
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nutrition = recipe.nutritionalInfo.perServing(servings: recipe.servings)
        
        let caloriesLabel = createNutritionLabel("Calories", value: "\(Int(nutrition.calories)) kcal")
        let proteinLabel = createNutritionLabel("Protein", value: "\(Int(nutrition.protein))g")
        let carbsLabel = createNutritionLabel("Carbs", value: "\(Int(nutrition.carbohydrates))g")
        let fatLabel = createNutritionLabel("Fat", value: "\(Int(nutrition.fat))g")
        
        container.addSubview(titleLabel)
        container.addSubview(caloriesLabel)
        container.addSubview(proteinLabel)
        container.addSubview(carbsLabel)
        container.addSubview(fatLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            caloriesLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            caloriesLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            proteinLabel.topAnchor.constraint(equalTo: caloriesLabel.bottomAnchor, constant: 8),
            proteinLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            carbsLabel.topAnchor.constraint(equalTo: proteinLabel.bottomAnchor, constant: 8),
            carbsLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            fatLabel.topAnchor.constraint(equalTo: carbsLabel.bottomAnchor, constant: 8),
            fatLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            fatLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        return container
    }
    
    private func createNutritionLabel(_ title: String, value: String) -> UILabel {
        let label = UILabel()
        label.text = "\(title): \(value)"
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }
    
    private func createHeaderLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }
    
    private func createIngredientLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }
    
    private func createInstructionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }
}
