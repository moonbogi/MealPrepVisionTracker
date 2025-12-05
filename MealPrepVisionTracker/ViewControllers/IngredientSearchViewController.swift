//
//  IngredientSearchViewController.swift
//  MealPrepVisionTracker
//
//  Created on 12/04/2025.
//

import UIKit

protocol IngredientSearchDelegate: AnyObject {
    func didSelectIngredient(_ ingredient: Ingredient)
}

class IngredientSearchViewController: UIViewController {
    
    weak var delegate: IngredientSearchDelegate?
    
    // MARK: - UI Components
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for ingredients..."
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(IngredientSearchCell.self, forCellReuseIdentifier: IngredientSearchCell.identifier)
        table.rowHeight = 80
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.configure(
            image: UIImage(systemName: "magnifyingglass"),
            title: "Search for Ingredients",
            message: "Use the search bar above to find ingredients from the Nutritionix database",
            actionTitle: nil
        )
        view.isHidden = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    
    private var searchResults: [NutritionixCommonFood] = []
    private var searchTask: DispatchWorkItem?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Add Ingredient"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Search
    
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            tableView.reloadData()
            updateEmptyState()
            return
        }
        
        // Cancel previous search
        searchTask?.cancel()
        
        // Show loading
        activityIndicator.startAnimating()
        emptyStateView.isHidden = true
        
        // Create new search task
        let task = DispatchWorkItem { [weak self] in
            NutritionixService.shared.searchIngredients(query: query) { result in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    
                    switch result {
                    case .success(let foods):
                        self?.searchResults = foods
                        self?.tableView.reloadData()
                        self?.updateEmptyState()
                        
                    case .failure(let error):
                        self?.showError(error)
                    }
                }
            }
        }
        
        searchTask = task
        
        // Debounce search by 0.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }
    
    private func updateEmptyState() {
        let hasSearchText = !(searchBar.text?.isEmpty ?? true)
        let hasResults = !searchResults.isEmpty
        
        if !hasSearchText {
            emptyStateView.configure(
                image: UIImage(systemName: "magnifyingglass"),
                title: "Search for Ingredients",
                message: "Use the search bar above to find ingredients from the Nutritionix database",
                actionTitle: nil
            )
            emptyStateView.isHidden = false
        } else if hasSearchText && !hasResults {
            emptyStateView.configure(
                image: UIImage(systemName: "exclamationmark.magnifyingglass"),
                title: "No Results Found",
                message: "Try searching with different keywords",
                actionTitle: nil
            )
            emptyStateView.isHidden = false
        } else {
            emptyStateView.isHidden = true
        }
    }
    
    private func showError(_ error: NutritionixError) {
        let alert = UIAlertController(
            title: "Search Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Ingredient Selection
    
    private func selectIngredient(at index: Int) {
        let food = searchResults[index]
        
        // Show loading
        activityIndicator.startAnimating()
        
        // Fetch detailed nutritional information
        NutritionixService.shared.getIngredientDetails(query: food.foodName) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let detailedFood):
                    let ingredient = NutritionixService.shared.convertToIngredient(from: detailedFood)
                    self?.showIngredientDetails(ingredient)
                    
                case .failure(_):
                    // Fallback to basic info if detailed fetch fails
                    let ingredient = NutritionixService.shared.convertToIngredient(from: food)
                    self?.showIngredientDetails(ingredient)
                }
            }
        }
    }
    
    private func showIngredientDetails(_ ingredient: Ingredient) {
        let detailVC = IngredientDetailViewController(ingredient: ingredient)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension IngredientSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearch(query: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDelegate & DataSource

extension IngredientSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IngredientSearchCell.identifier, for: indexPath) as? IngredientSearchCell else {
            return UITableViewCell()
        }
        
        let food = searchResults[indexPath.row]
        cell.configure(with: food)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectIngredient(at: indexPath.row)
    }
}

// MARK: - IngredientDetailDelegate

extension IngredientSearchViewController: IngredientDetailDelegate {
    func didSaveIngredient(_ ingredient: Ingredient) {
        delegate?.didSelectIngredient(ingredient)
        dismiss(animated: true)
    }
}

// MARK: - IngredientSearchCell

class IngredientSearchCell: UITableViewCell {
    static let identifier = "IngredientSearchCell"
    
    private let foodNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let servingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
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
        contentView.addSubview(foodNameLabel)
        contentView.addSubview(servingLabel)
        
        NSLayoutConstraint.activate([
            foodNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            foodNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            foodNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            servingLabel.topAnchor.constraint(equalTo: foodNameLabel.bottomAnchor, constant: 4),
            servingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            servingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            servingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with food: NutritionixCommonFood) {
        foodNameLabel.text = food.foodName.capitalized
        servingLabel.text = "\(food.servingQty) \(food.servingUnit)"
    }
}
