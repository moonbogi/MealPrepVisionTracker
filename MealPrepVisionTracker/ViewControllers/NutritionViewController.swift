//
//  NutritionViewController.swift
//  MealPrepVisionTracker
//
//  Created on 11/26/2025.
//

import UIKit

protocol NutritionPresentableListener: PresentableListener {
    func viewDidAppear()
    func didChangeDate(_ date: Date)
}

class NutritionViewController: UIViewController, NutritionPresentable {
    
    // MARK: - Properties
    
    weak var listener: PresentableListener? {
        get { return nutritionListener }
        set { nutritionListener = newValue as? NutritionPresentableListener }
    }
    
    private weak var nutritionListener: NutritionPresentableListener?
    
    private var mealPlans: [MealPlan] = []
    private var selectedDate = Date()
    
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
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let summaryCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No meal plans for this date\nCreate meal plans from recipes"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nutrition"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupNavigationBar()
        updateDateLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nutritionListener?.viewDidAppear()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        view.addSubview(emptyStateLabel)
        
        contentStack.addArrangedSubview(dateLabel)
        contentStack.addArrangedSubview(summaryCard)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            summaryCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 150),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupNavigationBar() {
        let prevButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(previousDay)
        )
        
        let nextButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.right"),
            style: .plain,
            target: self,
            action: #selector(nextDay)
        )
        
        let todayButton = UIBarButtonItem(
            title: "Today",
            style: .plain,
            target: self,
            action: #selector(goToToday)
        )
        
        navigationItem.leftBarButtonItems = [prevButton, todayButton]
        navigationItem.rightBarButtonItem = nextButton
    }
    
    // MARK: - NutritionPresentable
    
    func displayMealPlans(_ mealPlans: [MealPlan], for date: Date) {
        self.mealPlans = mealPlans
        self.selectedDate = date
        updateDateLabel()
        updateUI()
    }
    
    // MARK: - Private
    
    private func updateUI() {
        // Clear existing meal cards (keep date label and summary card)
        let viewsToRemove = contentStack.arrangedSubviews.dropFirst(2)
        viewsToRemove.forEach { $0.removeFromSuperview() }
        
        if mealPlans.isEmpty {
            emptyStateLabel.isHidden = false
            scrollView.isHidden = true
            return
        }
        
        emptyStateLabel.isHidden = true
        scrollView.isHidden = false
        
        // Update summary card
        updateSummaryCard()
        
        // Add meal plan cards
        for mealPlan in mealPlans {
            let mealCard = createMealCard(for: mealPlan)
            contentStack.addArrangedSubview(mealCard)
        }
    }
    
    private func updateSummaryCard() {
        // Remove all existing subviews
        summaryCard.subviews.forEach { $0.removeFromSuperview() }
        
        let totalNutrition = calculateTotalNutrition()
        
        let titleLabel = UILabel()
        titleLabel.text = "Daily Summary"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let caloriesLabel = createNutritionSummaryLabel("🔥 \(Int(totalNutrition.calories)) calories")
        let proteinLabel = createNutritionSummaryLabel("💪 \(Int(totalNutrition.protein))g protein")
        let carbsLabel = createNutritionSummaryLabel("🌾 \(Int(totalNutrition.carbohydrates))g carbs")
        let fatLabel = createNutritionSummaryLabel("🥑 \(Int(totalNutrition.fat))g fat")
        
        summaryCard.addSubview(titleLabel)
        summaryCard.addSubview(caloriesLabel)
        summaryCard.addSubview(proteinLabel)
        summaryCard.addSubview(carbsLabel)
        summaryCard.addSubview(fatLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),
            
            caloriesLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            caloriesLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),
            
            proteinLabel.topAnchor.constraint(equalTo: caloriesLabel.bottomAnchor, constant: 8),
            proteinLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),
            
            carbsLabel.topAnchor.constraint(equalTo: proteinLabel.bottomAnchor, constant: 8),
            carbsLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),
            
            fatLabel.topAnchor.constraint(equalTo: carbsLabel.bottomAnchor, constant: 8),
            fatLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),
            fatLabel.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func calculateTotalNutrition() -> NutritionalInfo {
        var totalCalories = 0.0
        var totalProtein = 0.0
        var totalCarbs = 0.0
        var totalFat = 0.0
        var totalFiber = 0.0
        var totalSugar = 0.0
        var totalSodium = 0.0
        var totalCholesterol = 0.0
        
        for mealPlan in mealPlans {
            let nutrition = mealPlan.nutritionalInfo
            totalCalories += nutrition.calories
            totalProtein += nutrition.protein
            totalCarbs += nutrition.carbohydrates
            totalFat += nutrition.fat
            totalFiber += nutrition.fiber
            totalSugar += nutrition.sugar
            totalSodium += nutrition.sodium
            totalCholesterol += nutrition.cholesterol
        }
        
        return NutritionalInfo(
            calories: totalCalories,
            protein: totalProtein,
            carbohydrates: totalCarbs,
            fat: totalFat,
            fiber: totalFiber,
            sugar: totalSugar,
            sodium: totalSodium,
            cholesterol: totalCholesterol
        )
    }
    
    private func createMealCard(for mealPlan: MealPlan) -> UIView {
        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray4.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let mealTypeLabel = UILabel()
        mealTypeLabel.text = "\(mealPlan.mealType.emoji) \(mealPlan.mealType.displayName)"
        mealTypeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        mealTypeLabel.textColor = .secondaryLabel
        mealTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let recipeLabel = UILabel()
        recipeLabel.text = mealPlan.recipe.name
        recipeLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        recipeLabel.numberOfLines = 0
        recipeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nutrition = mealPlan.nutritionalInfo
        let nutritionLabel = UILabel()
        nutritionLabel.text = "\(Int(nutrition.calories)) cal • \(Int(nutrition.protein))g protein"
        nutritionLabel.font = .systemFont(ofSize: 14)
        nutritionLabel.textColor = .tertiaryLabel
        nutritionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(mealTypeLabel)
        card.addSubview(recipeLabel)
        card.addSubview(nutritionLabel)
        
        NSLayoutConstraint.activate([
            mealTypeLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            mealTypeLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            
            recipeLabel.topAnchor.constraint(equalTo: mealTypeLabel.bottomAnchor, constant: 8),
            recipeLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            recipeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            
            nutritionLabel.topAnchor.constraint(equalTo: recipeLabel.bottomAnchor, constant: 8),
            nutritionLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            nutritionLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        return card
    }
    
    private func createNutritionSummaryLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        dateLabel.text = formatter.string(from: selectedDate)
    }
    
    // MARK: - Actions
    
    @objc private func previousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        nutritionListener?.didChangeDate(selectedDate)
    }
    
    @objc private func nextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        nutritionListener?.didChangeDate(selectedDate)
    }
    
    @objc private func goToToday() {
        selectedDate = Date()
        nutritionListener?.didChangeDate(selectedDate)
    }
}
