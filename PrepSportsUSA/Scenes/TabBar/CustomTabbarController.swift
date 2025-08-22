//
//  CustomTabbarController.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 01/01/2025.
//

import RxSwift
import RxCocoa

class CustomTabbarController: UITabBarController {
    
    var viewModel: CustomTabbarViewModel!
    
    private var homeViewController: HomeViewController!
    private var storiesViewController: StoriesViewController!
    private var trafficViewController: TrafficViewController!
    private var moreViewController: MoreViewController!
    private var searchViewController: SearchViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = CustomTabbarViewModel()
        viewModel.delegate = self
        
        createTabbarElements()
        setupView()
        
        DispatchQueue.main.async {
            self.handleLoginRouting()
            self.handleLogoutRouting()
        }
        
        viewModel.viewDidLoad()
        
        storiesViewController.loadViewIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
    
    deinit {
        print("CustomTabbarController released ♻️!")
    }
    
    private func setupView() {
        tabBar.isTranslucent = true
        updateAppearance()
    }
    
    private func standardTabbarAppearance() -> UITabBarAppearance {
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: RikstotoStyle.Primary.rikstotoGreen,
            .font: UIFont.robotoRegular(size: 12)
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: RikstotoStyle.Primary.rikstotoGreen,
            .font: UIFont.robotoBold(size: 12)
        ]
        
        appearance.stackedLayoutAppearance.normal.iconColor = RikstotoStyle.Primary.rikstotoGreen
        appearance.stackedLayoutAppearance.selected.iconColor = RikstotoStyle.Primary.rikstotoGreen
        
        appearance.inlineLayoutAppearance = appearance.stackedLayoutAppearance
        appearance.compactInlineLayoutAppearance = appearance.stackedLayoutAppearance
        
        appearance.backgroundColor = RikstotoStyle.Primary.barBackgroundColor
        
        return appearance
    }
    
    private func createTabbarElements() {
        // Home Tab
        homeViewController = UIViewController.getViewControllerFrom(name: .home) as? HomeViewController
        homeViewController.tabBarItem = UITabBarItem(title: "Home",
                                                  image: UIImage(named: "home_unselected")?.withRenderingMode(.alwaysOriginal),
                                                  selectedImage: UIImage(named: "home_selected")?.withRenderingMode(.alwaysOriginal))
        
        // Stories Tab
        storiesViewController = UIViewController.getViewControllerFrom(name: .stories) as? StoriesViewController
        storiesViewController.tabBarItem = UITabBarItem(title: "Stories",
                                                    image: UIImage(named: "Article")?.withRenderingMode(.alwaysOriginal),
                                                    selectedImage: UIImage(named: "Article")?.withRenderingMode(.alwaysOriginal))
        
        // Search Tab
        searchViewController = UIViewController.getViewControllerFrom(name: .search) as? SearchViewController
        searchViewController.tabBarItem = UITabBarItem(title: "Search",
                                                     image: UIImage(named: "MagnifyingGlass")?.withRenderingMode(.alwaysOriginal),
                                                     selectedImage: UIImage(named: "MagnifyingGlass")?.withRenderingMode(.alwaysOriginal))
        
        // More Tab
        moreViewController = UIViewController.getViewControllerFrom(name: .more) as? MoreViewController
        moreViewController.tabBarItem = UITabBarItem(title: "More",
                                                           image: UIImage(named: "DotsThreeCircle")?.withRenderingMode(.alwaysOriginal),
                                                           selectedImage: UIImage(named: "DotsThreeCircle")?.withRenderingMode(.alwaysOriginal))
        
        let tabs = [homeViewController, storiesViewController, searchViewController, moreViewController].map {
            UINavigationController(rootViewController: $0!)
        }
        
        viewControllers = tabs
    }
    
    // MARK: customizable
    init() {
        super.init(nibName: nil, bundle: nil)
        object_setClass(self.tabBar, CustomTabbar.self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var selectedViewController: UIViewController? {
        get {
            super.selectedViewController
        }
        set {
            super.selectedViewController = newValue
            updateAppearance()
        }
    }
    
    func updateAppearance() {
        let transparentAppearance = selectedViewController === homeViewController || selectedViewController === homeViewController.navigationController
        let appearance = standardTabbarAppearance()
        if transparentAppearance {
            appearance.configureWithTransparentBackground()
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        } else {
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = nil
            }
        }
        
        tabBar.standardAppearance = appearance
    }
    
    public func selectStoriesViewController() {
        if let navigationController = viewControllers?[1] as? UINavigationController,
            let storiesVC = navigationController.viewControllers.first as? StoriesViewController {
            selectedIndex = 1
            updateAppearance()
        }
    }
    
    public func selectSearchViewController() {
        if let navigationController = viewControllers?[2] as? UINavigationController,
            let searchVC = navigationController.viewControllers.first as? SearchViewController {
            selectedIndex = 2
            updateAppearance()
        }
    }
    
    private func handleLoginRouting() {
        
        defer { RKStorage.shared.loginFlowStartingPoint = nil }
        guard RKStorage.shared.tokenExists() else { return }
        guard let startingPoint = RKStorage.shared.loginFlowStartingPoint else { return }
        
        switch startingPoint {
        case .homeGameOverlay:
            break
        case .result:
            selectedViewController = storiesViewController.navigationController
        default:
            break
        }
    }
    
    private func handleLogoutRouting() {
        guard !RKStorage.shared.tokenExists() else { return }
        // Handle logout routing if needed
    }
}

extension CustomTabbarController: CustomTabbarViewModelDelegate {
    
    func unreadMessageUpdated(hasUnread: Bool) {
        // Handle unread messages if needed
    }
    
    func networkStatus(isReachable: Bool) {
        // Handle network status if needed
    }
}

// MARK: - tabbar with custom height
final class CustomTabbar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 100
        return sizeThatFits
    }
}
