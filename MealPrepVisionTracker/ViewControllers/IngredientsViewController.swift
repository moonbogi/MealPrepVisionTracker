//
//  IngredientsViewController.swift
//  MealPrepVisionTracker
//
//  Created on 11/26/2025.
//

import UIKit

protocol IngredientsPresentableListener: PresentableListener {
    func viewDidAppear()
    func didAddIngredient(name: String)
    func didDeleteIngredient(_ ingredient: Ingredient)
}

class IngredientsViewController: UIViewController, IngredientsPresentable {
    
    // MARK: - Properties
    
    weak var listener: PresentableListener? {
        get { return ingredientsListener }
        set { ingredientsListener = newValue as? IngredientsPresentableListener }
    }
    
    private weak var ingredientsListener: IngredientsPresentableListener?
    
    private var ingredients: [Ingredient] = []
    private var filteredIngredients: [Ingredient] = []
    private var isSearching = false
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(IngredientDetailCell.self, forCellReuseIdentifier: IngredientDetailCell.identifier)
        return table
    }()
    
    private let searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search ingredients"
        return search
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView.ingredients()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.actionHandler = { [weak self] in
            self?.tabBarController?.selectedIndex = 0
        }
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Pantry"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupSearchController()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ingredientsListener?.viewDidAppear()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Accessibility
        tableView.accessibilityLabel = "Ingredients list"
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Add ingredient manually"
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupNavigationBar() {
        let addManualButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addIngredientManually)
        )
        
        let searchAPIButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass.circle"),
            style: .plain,
            target: self,
            action: #selector(searchFromAPI)
        )
        
        navigationItem.rightBarButtonItems = [addManualButton, searchAPIButton]
    }
    
    // MARK: - IngredientsPresentable
    
    func displayIngredients(_ ingredients: [Ingredient]) {
        self.ingredients = ingredients
        self.filteredIngredients = ingredients
        updateEmptyState()
        tableView.reloadData()
    }
    
    // MARK: - Private
    
    private func updateEmptyState() {
        let dataToShow = isSearching ? filteredIngredients : ingredients
        let isEmpty = dataToShow.isEmpty
        
        if isSearching && isEmpty {
            // Show search-specific empty state
            emptyStateView.configure(
                image: UIImage(systemName: "magnifyingglass"),
                title: "No Results Found",
                message: "No ingredients match '\(searchController.searchBar.text ?? "")'",
                actionTitle: nil,
                actionHandler: nil
            )
            emptyStateView.isHidden = false
            tableView.isHidden = true
        } else if !isSearching && isEmpty {
            // Show default empty state
            emptyStateView.configure(
                image: UIImage(systemName: "basket"),
                title: "No Ingredients Yet",
                message: "Start building your pantry by scanning ingredients with your camera.",
                actionTitle: "Scan Ingredient",
                actionHandler: { [weak self] in
                    self?.tabBarController?.selectedIndex = 0
                }
            )
            emptyStateView.isHidden = false
            tableView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    // MARK: - Actions
    
    @objc private func addIngredientManually() {
        let alert = UIAlertController(title: "Add Ingredient", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Ingredient name"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            self?.ingredientsListener?.didAddIngredient(name: name)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func searchFromAPI() {
        let searchVC = IngredientSearchViewController()
        searchVC.delegate = self
        let navController = UINavigationController(rootViewController: searchVC)
        present(navController, animated: true)
    }
}

// MARK: - IngredientSearchDelegate

extension IngredientsViewController: IngredientSearchDelegate {
    func didSelectIngredient(_ ingredient: Ingredient) {
        // Ingredient already saved to Core Data by IngredientDetailViewController
        ingredientsListener?.viewDidAppear() // Refresh the list
    }
}

// MARK: - UITableViewDataSource

extension IngredientsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return IngredientCategory.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = IngredientCategory.allCases[section]
        let ingredients = isSearching ? filteredIngredients : self.ingredients
        return ingredients.filter { $0.category == category }.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = IngredientCategory.allCases[section]
        let ingredients = isSearching ? filteredIngredients : self.ingredients
        let count = ingredients.filter { $0.category == category }.count
        
        return count > 0 ? "\(category.emoji) \(category.displayName)" : nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IngredientDetailCell.identifier, for: indexPath) as? IngredientDetailCell else {
            return UITableViewCell()
        }
        
        let category = IngredientCategory.allCases[indexPath.section]
        let ingredients = isSearching ? filteredIngredients : self.ingredients
        let categoryIngredients = ingredients.filter { $0.category == category }
        
        if indexPath.row < categoryIngredients.count {
            cell.configure(with: categoryIngredients[indexPath.row])
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension IngredientsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let category = IngredientCategory.allCases[indexPath.section]
        let ingredients = isSearching ? filteredIngredients : self.ingredients
        let categoryIngredients = ingredients.filter { $0.category == category }
        
        guard indexPath.row < categoryIngredients.count else { return nil }
        let ingredient = categoryIngredients[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.ingredientsListener?.didDeleteIngredient(ingredient)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - UISearchResultsUpdating

extension IngredientsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            isSearching = false
            filteredIngredients = ingredients
            updateEmptyState()
            tableView.reloadData()
            return
        }
        
        isSearching = true
        filteredIngredients = ingredients.filter { ingredient in
            // Search in name, category, and quantity unit
            let searchLower = searchText.lowercased()
            return ingredient.name.lowercased().contains(searchLower) ||
                   ingredient.category.displayName.lowercased().contains(searchLower) ||
                   ingredient.unit.rawValue.lowercased().contains(searchLower) ||
                   ingredient.unit.abbreviation.lowercased().contains(searchLower)
        }
        updateEmptyState()
        tableView.reloadData()
    }
}

// MARK: - IngredientDetailCell

class IngredientDetailCell: UITableViewCell {
    
    static let identifier = "IngredientDetailCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .tertiaryLabel
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
        contentView.addSubview(quantityLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            quantityLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            quantityLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            quantityLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: quantityLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with ingredient: Ingredient) {
        nameLabel.text = ingredient.name
        quantityLabel.text = "\(ingredient.quantity) \(ingredient.unit.abbreviation)"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel.text = "Added: \(formatter.string(from: ingredient.dateAdded))"
    }
}
