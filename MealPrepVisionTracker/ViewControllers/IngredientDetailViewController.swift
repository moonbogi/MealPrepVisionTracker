//
//  IngredientDetailViewController.swift
//  MealPrepVisionTracker
//
//  Created on 12/04/2025.
//

import UIKit

protocol IngredientDetailDelegate: AnyObject {
    func didSaveIngredient(_ ingredient: Ingredient)
}

class IngredientDetailViewController: UIViewController {
    
    weak var delegate: IngredientDetailDelegate?
    private var ingredient: Ingredient
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.text = "Quantity"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quantityTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.text = "Unit"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let unitPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Pantry", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(named: "BrandGreen") ?? .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    private let allUnits = MeasurementUnit.allCases
    private var selectedUnitIndex: Int = 0
    
    // MARK: - Initialization
    
    init(ingredient: Ingredient) {
        self.ingredient = ingredient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureWithIngredient()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Ingredient Details"
        view.backgroundColor = .systemBackground
        
        unitPicker.delegate = self
        unitPicker.dataSource = self
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(quantityTextField)
        contentView.addSubview(unitLabel)
        contentView.addSubview(unitPicker)
        contentView.addSubview(saveButton)
        
        // Accessibility
        nameLabel.accessibilityLabel = "Ingredient name"
        categoryLabel.accessibilityLabel = "Category"
        quantityTextField.accessibilityLabel = "Quantity"
        unitPicker.accessibilityLabel = "Measurement unit"
        saveButton.accessibilityLabel = "Add ingredient to pantry"
    }
    
    private func setupConstraints() {
        let contentLayoutGuide = scrollView.contentLayoutGuide
        let frameLayoutGuide = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            categoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            quantityLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 32),
            quantityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            quantityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            quantityTextField.topAnchor.constraint(equalTo: quantityLabel.bottomAnchor, constant: 8),
            quantityTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            quantityTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            quantityTextField.heightAnchor.constraint(equalToConstant: 44),
            
            unitLabel.topAnchor.constraint(equalTo: quantityTextField.bottomAnchor, constant: 24),
            unitLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            unitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            unitPicker.topAnchor.constraint(equalTo: unitLabel.bottomAnchor, constant: 8),
            unitPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            unitPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            unitPicker.heightAnchor.constraint(equalToConstant: 150),
            
            saveButton.topAnchor.constraint(equalTo: unitPicker.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func configureWithIngredient() {
        nameLabel.text = ingredient.name
        categoryLabel.text = ingredient.category.displayName
        quantityTextField.text = String(format: "%.1f", ingredient.quantity)
        
        // Set unit picker to current unit
        if let index = allUnits.firstIndex(of: ingredient.unit) {
            selectedUnitIndex = index
            unitPicker.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func saveTapped() {
        guard let quantityText = quantityTextField.text,
              let quantity = Double(quantityText),
              quantity > 0 else {
            showAlert(title: "Invalid Quantity", message: "Please enter a valid quantity greater than 0")
            return
        }
        
        let selectedUnit = allUnits[selectedUnitIndex]
        
        // Update ingredient with user's selections
        let updatedIngredient = Ingredient(
            id: ingredient.id,
            name: ingredient.name,
            category: ingredient.category,
            quantity: quantity,
            unit: selectedUnit,
            dateAdded: Date(),
            expirationDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            imageData: ingredient.imageData,
            confidence: ingredient.confidence
        )
        
        // Save to Core Data
        CoreDataManager.shared.saveIngredient(updatedIngredient)
        
        // Notify delegate
        delegate?.didSaveIngredient(updatedIngredient)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDelegate & DataSource

extension IngredientDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allUnits.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allUnits[row].displayName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUnitIndex = row
    }
}
