//
//  EmptyStateView.swift
//  MealPrepVisionTracker
//
//  Created on 11/28/2025.
//

import UIKit

class EmptyStateView: UIView {
    
    // MARK: - Properties
    
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        return stack
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGray3
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 28, bottom: 14, right: 28)
        return button
    }()
    
    var actionHandler: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    convenience init(
        image: UIImage?,
        title: String,
        message: String,
        actionTitle: String? = nil,
        actionHandler: (() -> Void)? = nil
    ) {
        self.init(frame: .zero)
        configure(image: image, title: title, message: message, actionTitle: actionTitle, actionHandler: actionHandler)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(containerStack)
        containerStack.addArrangedSubview(imageView)
        containerStack.addArrangedSubview(titleLabel)
        containerStack.addArrangedSubview(messageLabel)
        containerStack.addArrangedSubview(actionButton)
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerStack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            containerStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            containerStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
            
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            actionButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(
        image: UIImage?,
        title: String,
        message: String,
        actionTitle: String? = nil,
        actionHandler: (() -> Void)? = nil
    ) {
        imageView.image = image
        titleLabel.text = title
        messageLabel.text = message
        self.actionHandler = actionHandler
        
        if let actionTitle = actionTitle {
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.isHidden = false
            actionButton.accessibilityLabel = actionTitle
        } else {
            actionButton.isHidden = true
        }
        
        // Accessibility
        imageView.isAccessibilityElement = false
        titleLabel.accessibilityTraits = .header
        isAccessibilityElement = false
        accessibilityElements = [titleLabel, messageLabel, actionButton].filter { !$0.isHidden }
    }
    
    // MARK: - Actions
    
    @objc private func actionButtonTapped() {
        actionHandler?()
    }
    
    // MARK: - Convenience Factory Methods
    
    static func camera() -> EmptyStateView {
        return EmptyStateView(
            image: UIImage(systemName: "camera.fill"),
            title: "No Camera Access",
            message: "To scan ingredients, please allow camera access in Settings.",
            actionTitle: "Open Settings",
            actionHandler: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        )
    }
    
    static func ingredients() -> EmptyStateView {
        return EmptyStateView(
            image: UIImage(systemName: "basket"),
            title: "No Ingredients Yet",
            message: "Start building your pantry by scanning ingredients with your camera.",
            actionTitle: "Scan Ingredient",
            actionHandler: nil // Set this from the view controller
        )
    }
    
    static func recipes() -> EmptyStateView {
        return EmptyStateView(
            image: UIImage(systemName: "book.closed"),
            title: "No Recipes Found",
            message: "Add ingredients to your pantry to discover personalized recipe suggestions.",
            actionTitle: "Add Ingredients",
            actionHandler: nil // Set this from the view controller
        )
    }
    
    static func nutrition() -> EmptyStateView {
        return EmptyStateView(
            image: UIImage(systemName: "chart.bar"),
            title: "No Nutrition Data",
            message: "Start tracking your meals to see detailed nutrition insights.",
            actionTitle: nil,
            actionHandler: nil
        )
    }
    
    static func searchResults() -> EmptyStateView {
        return EmptyStateView(
            image: UIImage(systemName: "magnifyingglass"),
            title: "No Results Found",
            message: "Try adjusting your search or add more ingredients to your pantry.",
            actionTitle: nil,
            actionHandler: nil
        )
    }
}
