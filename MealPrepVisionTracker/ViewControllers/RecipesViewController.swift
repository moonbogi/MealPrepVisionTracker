//
//  RecipesViewController.swift
//  MealPrepVisionTracker
//
//  Created on 11/26/2025.
//

import UIKit

protocol RecipesPresentableListener: PresentableListener {
    func viewDidAppear()
    func didSelectRecipe(_ recipe: Recipe)
}

class RecipesViewController: UIViewController, RecipesPresentable {
    
    // MARK: - Properties
    
    weak var listener: PresentableListener? {
        get { return recipesListener }
        set { recipesListener = newValue as? RecipesPresentableListener }
    }
    
    private weak var recipesListener: RecipesPresentableListener?
    
    private var matchedRecipes: [Recipe] = []
    private var allRecipes: [Recipe] = []
    private var showingMatches = true
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(RecipeCell.self, forCellReuseIdentifier: RecipeCell.identifier)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120
        return table
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Matches", "All Recipes"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView.recipes()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.actionHandler = { [weak self] in
            self?.tabBarController?.selectedIndex = 1
        }
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Recipes"
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupUI()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "photo.on.rectangle.angled"),
            style: .plain,
            target: self,
            action: #selector(generateFromImageTapped)
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Generate recipe from image"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recipesListener?.viewDidAppear()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        // Accessibility
        segmentedControl.accessibilityLabel = "Recipe filter"
        tableView.accessibilityLabel = "Recipes list"
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - RecipesPresentable
    
    func displayRecipes(matched: [Recipe], all: [Recipe]) {
        self.matchedRecipes = matched
        self.allRecipes = all
        updateEmptyState()
        tableView.reloadData()
    }
    
    // MARK: - Private
    
    private func updateEmptyState() {
        let isEmpty = showingMatches ? matchedRecipes.isEmpty : allRecipes.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    // MARK: - Actions
    
    @objc private func segmentChanged() {
        showingMatches = segmentedControl.selectedSegmentIndex == 0
        updateEmptyState()
        tableView.reloadData()
    }
    
    @objc private func generateFromImageTapped() {
        let recipeFromImageVC = RecipeFromImageViewController()
        recipeFromImageVC.delegate = self
        let navController = UINavigationController(rootViewController: recipeFromImageVC)
        present(navController, animated: true)
    }
}

// MARK: - RecipeFromImageDelegate

extension RecipesViewController: RecipeFromImageDelegate {
    func didGenerateRecipe(_ detectedRecipe: DetectedRecipe) {
        // Convert DetectedRecipe to Recipe model
        let recipeIngredients = detectedRecipe.ingredients.map { detectedIngredient in
            RecipeIngredient(
                name: detectedIngredient.name,
                quantity: Double(detectedIngredient.quantity) ?? 1.0,
                unit: .item,
                notes: detectedIngredient.unit
            )
        }
        
        // Create basic nutritional info (can be enhanced later)
        let nutritionalInfo = NutritionalInfo(
            calories: 0,
            protein: 0,
            carbohydrates: 0,
            fat: 0,
            fiber: 0,
            sugar: 0
        )
        
        let recipe = Recipe(
            name: detectedRecipe.name,
            description: detectedRecipe.description,
            requiredIngredients: recipeIngredients,
            optionalIngredients: [],
            instructions: detectedRecipe.instructions,
            prepTime: detectedRecipe.estimatedPrepTime,
            cookTime: 0,
            servings: detectedRecipe.estimatedServings,
            difficulty: .medium,
            nutritionalInfo: nutritionalInfo,
            imageURL: nil,
            tags: []
        )
        
        // Save recipe using RecipeService
        RecipeService.shared.addRecipe(recipe)
        
        // Show success message
        let alert = UIAlertController(
            title: "Recipe Saved!",
            message: "\(recipe.name) has been added to your recipes.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.recipesListener?.viewDidAppear() // Refresh list
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension RecipesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingMatches ? matchedRecipes.count : allRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeCell.identifier, for: indexPath) as? RecipeCell else {
            return UITableViewCell()
        }
        
        let recipe = showingMatches ? matchedRecipes[indexPath.row] : allRecipes[indexPath.row]
        cell.configure(with: recipe, showMatch: showingMatches)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension RecipesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recipe = showingMatches ? matchedRecipes[indexPath.row] : allRecipes[indexPath.row]
        recipesListener?.didSelectRecipe(recipe)
    }
}

// MARK: - RecipeCell

class RecipeCell: UITableViewCell {
    
    static let identifier = "RecipeCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let matchLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let difficultyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let caloriesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(matchLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(difficultyLabel)
        contentView.addSubview(caloriesLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            matchLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            matchLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: matchLabel.bottomAnchor, constant: 4),
            infoLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            difficultyLabel.centerYAnchor.constraint(equalTo: infoLabel.centerYAnchor),
            difficultyLabel.leadingAnchor.constraint(equalTo: infoLabel.trailingAnchor, constant: 12),
            
            caloriesLabel.centerYAnchor.constraint(equalTo: infoLabel.centerYAnchor),
            caloriesLabel.leadingAnchor.constraint(equalTo: difficultyLabel.trailingAnchor, constant: 12)
        ])
    }
    
    func configure(with recipe: Recipe, showMatch: Bool) {
        nameLabel.text = recipe.name
        descriptionLabel.text = recipe.description
        
        let totalTime = recipe.prepTime + recipe.cookTime
        infoLabel.text = "⏱ \(totalTime) min • 🍽 \(recipe.servings) servings"
        difficultyLabel.text = "\(recipe.difficulty.emoji) \(recipe.difficulty.displayName)"
        caloriesLabel.text = "🔥 \(Int(recipe.nutritionalInfo.calories)) cal"
        
        if showMatch {
            matchLabel.isHidden = false
            matchLabel.text = String(format: "✓ %.0f%% Match", recipe.matchPercentage)
        } else {
            matchLabel.isHidden = true
        }
    }
}
