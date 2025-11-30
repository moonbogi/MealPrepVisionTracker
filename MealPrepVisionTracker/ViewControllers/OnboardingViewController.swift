//
//  OnboardingViewController.swift
//  MealPrepVisionTracker
//
//  Created on 11/28/2025.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    
    private let pageViewController: UIPageViewController = {
        let pvc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        return pvc
    }()
    
    private lazy var pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Meal Prep Vision Tracker",
            description: "Your personal AI-powered meal planning assistant. Scan ingredients, discover recipes, and track your nutrition effortlessly.",
            imageName: "fork.knife.circle.fill",
            color: .systemGreen
        ),
        OnboardingPage(
            title: "Scan Ingredients",
            description: "Use your camera to instantly identify ingredients. Our advanced Vision AI recognizes hundreds of food items with high accuracy.",
            imageName: "camera.fill",
            color: .systemBlue
        ),
        OnboardingPage(
            title: "Manage Your Pantry",
            description: "Keep track of all your ingredients in one place. See what's available and get notified when items are running low.",
            imageName: "basket.fill",
            color: .systemOrange
        ),
        OnboardingPage(
            title: "Discover Recipes",
            description: "Get personalized recipe suggestions based on your available ingredients. Cook with what you have!",
            imageName: "book.fill",
            color: .systemPurple
        ),
        OnboardingPage(
            title: "Track Nutrition",
            description: "Monitor your daily nutrition intake with detailed breakdowns of calories, macros, and micronutrients.",
            imageName: "chart.bar.fill",
            color: .systemPink
        )
    ]
    
    private var currentPageIndex = 0
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPageIndicatorTintColor = .systemGreen
        pc.pageIndicatorTintColor = .systemGray4
        pc.isUserInteractionEnabled = false
        return pc
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.accessibilityLabel = "Next page"
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.setTitleColor(.systemGray, for: .normal)
        button.accessibilityLabel = "Skip tutorial"
        return button
    }()
    
    var onComplete: (() -> Void)?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPageViewController()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add page view controller
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add controls
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        view.addSubview(skipButton)
        
        // Configure page control
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        // Button actions
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        
        // Layout
        NSLayoutConstraint.activate([
            // Page view controller
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            
            // Page control
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            
            // Next button
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nextButton.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Skip button
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            skipButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupPageViewController() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let firstPage = createPageViewController(for: 0) {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: false)
        }
    }
    
    private func createPageViewController(for index: Int) -> OnboardingPageViewController? {
        guard index >= 0 && index < pages.count else { return nil }
        let pageVC = OnboardingPageViewController()
        pageVC.configure(with: pages[index])
        pageVC.pageIndex = index
        return pageVC
    }
    
    // MARK: - Actions
    
    @objc private func nextButtonTapped() {
        if currentPageIndex < pages.count - 1 {
            currentPageIndex += 1
            if let nextPage = createPageViewController(for: currentPageIndex) {
                pageViewController.setViewControllers([nextPage], direction: .forward, animated: true)
                updateUI()
            }
        } else {
            completeOnboarding()
        }
    }
    
    @objc private func skipButtonTapped() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        onComplete?()
    }
    
    private func updateUI() {
        pageControl.currentPage = currentPageIndex
        
        if currentPageIndex == pages.count - 1 {
            nextButton.setTitle("Get Started", for: .normal)
            nextButton.accessibilityLabel = "Get started with the app"
            skipButton.isHidden = true
        } else {
            nextButton.setTitle("Next", for: .normal)
            nextButton.accessibilityLabel = "Next page"
            skipButton.isHidden = false
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageVC = viewController as? OnboardingPageViewController,
              let index = pageVC.pageIndex,
              index > 0 else {
            return nil
        }
        return createPageViewController(for: index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageVC = viewController as? OnboardingPageViewController,
              let index = pageVC.pageIndex,
              index < pages.count - 1 else {
            return nil
        }
        return createPageViewController(for: index + 1)
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let visibleVC = pageViewController.viewControllers?.first as? OnboardingPageViewController,
              let index = visibleVC.pageIndex else {
            return
        }
        currentPageIndex = index
        updateUI()
    }
}

// MARK: - Supporting Types

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let color: UIColor
}

class OnboardingPageViewController: UIViewController {
    
    var pageIndex: Int?
    
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 32
        stack.alignment = .center
        return stack
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGreen
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerStack)
        containerStack.addArrangedSubview(iconImageView)
        containerStack.addArrangedSubview(titleLabel)
        containerStack.addArrangedSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            containerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            containerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            containerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 120),
            iconImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    func configure(with page: OnboardingPage) {
        iconImageView.image = UIImage(systemName: page.imageName)
        iconImageView.tintColor = page.color
        titleLabel.text = page.title
        descriptionLabel.text = page.description
        
        // Accessibility
        iconImageView.isAccessibilityElement = false
        titleLabel.accessibilityTraits = .header
    }
}
