//
//  SportsRouter.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 22/08/2025.
//

import UIKit

class SportsRouter: BaseRouter {
    weak var viewController: SportsViewController!
    
    init(_ viewController: SportsViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Main Navigation Routes
    func routeToHome() {
        guard let destination = UIViewController.getViewControllerFor(name: .home) as? HomeViewController else { return }
        navigate(from: viewController, to: destination)
    }
    
    func routeToStories() {
        guard let destination = UIViewController.getViewControllerFor(name: .stories) as? StoriesViewController else { return }
        navigate(from: viewController, to: destination)
    }
    
    func routeToSearch() {
        guard let destination = UIViewController.getViewControllerFor(name: .search) as? SearchViewController else { return }
        navigate(from: viewController, to: destination)
    }
    
    func routeToMore() {
        guard let destination = UIViewController.getViewControllerFor(name: .more) as? MoreViewController else { return }
        navigate(from: viewController, to: destination)
    }
    
    // MARK: - Sports Specific Routes
    func routeToStoryView(storyId: Int) {
        // Create story view controller with specific story ID
        let storyViewVC = StoryViewViewController()
        storyViewVC.storyId = storyId
        navigate(from: viewController, to: storyViewVC)
    }
    
    func routeToLocationList(fromHome: Bool, id: Int) {
        let locationListVC = LocationListViewController()
        locationListVC.configure(fromHome: fromHome, id: id)
        navigate(from: viewController, to: locationListVC)
    }
    
    func routeToOrganizationList(fromHome: Bool, id: Int) {
        let organizationListVC = OrganizationListViewController()
        organizationListVC.configure(fromHome: fromHome, id: id)
        navigate(from: viewController, to: organizationListVC)
    }
    
    func routeToOutboundList(fromHome: Bool, id: Int) {
        let outboundListVC = OutboundListViewController()
        outboundListVC.configure(fromHome: fromHome, id: id)
        navigate(from: viewController, to: outboundListVC)
    }
    
    func routeToMap(fromHome: Bool, id: Int) {
        guard let mapVC = UIViewController.getViewControllerFor(name: .map) as? MapViewController else { return }
        // Configure map view controller with parameters
        mapVC.configure(fromHome: fromHome, id: id)
        navigate(from: viewController, to: mapVC)
    }
    
    func routeToProjectStories() {
        guard let projectStoriesVC = UIViewController.getViewControllerFor(name: .projectStories) as? ProjectStoriesViewController else { return }
        navigate(from: viewController, to: projectStoriesVC)
    }
    
    func routeToSportsBriefDetail(prePitchId: Int) {
        let storyboard = UIStoryboard(name: "SportsBriefDetail", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SportsBriefDetailViewController") as? SportsBriefDetailViewController else { return }
        let vm = SportsBriefDetailViewModel(prePitchId: prePitchId)
        vc.viewModel = vm
        vc.router = SportsBriefDetailRouter(vc)
        navigate(from: viewController, to: vc)
    }
    
    func routeToAddSportsBriefs() {
        guard let addSportsBriefVC = UIViewController.getViewControllerFor(name: .addSportsBrief) as? AddSportsBriefViewController else {
            // Fallback to programmatic creation if storyboard not available
            let addSportsBriefVC = AddSportsBriefViewController()
            navigate(from: viewController, to: addSportsBriefVC)
            return
        }
        navigate(from: viewController, to: addSportsBriefVC)
    }
    
    func routeToUpdatePassword() {
        let updatePasswordVC = UpdatePasswordViewController()
        navigate(from: viewController, to: updatePasswordVC)
    }
    
    func routeToProfileView() {
        let profileViewVC = ProfileViewViewController()
        navigate(from: viewController, to: profileViewVC)
    }
    
    // MARK: - Search Routes
    func routeToSearchStories() {
        let searchStoriesVC = SearchStoriesViewController()
        navigate(from: viewController, to: searchStoriesVC)
    }
}

// MARK: - Placeholder ViewControllers
// These would be actual view controllers in your project

class StoryViewViewController: UIViewController {
    var storyId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "Story View"
        
        let label = UILabel()
        label.text = "Story View - ID: \(storyId)"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

class LocationListViewController: UIViewController {
    private var fromHome: Bool = false
    private var locationId: Int = 0
    
    func configure(fromHome: Bool, id: Int) {
        self.fromHome = fromHome
        self.locationId = id
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "Location List"
        
        let label = UILabel()
        label.text = "Location List\nFrom Home: \(fromHome)\nID: \(locationId)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

class OrganizationListViewController: UIViewController {
    private var fromHome: Bool = false
    private var organizationId: Int = 0
    
    func configure(fromHome: Bool, id: Int) {
        self.fromHome = fromHome
        self.organizationId = id
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "Organization List"
        
        let label = UILabel()
        label.text = "Organization List\nFrom Home: \(fromHome)\nID: \(organizationId)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

class OutboundListViewController: UIViewController {
    private var fromHome: Bool = false
    private var outboundId: Int = 0
    
    func configure(fromHome: Bool, id: Int) {
        self.fromHome = fromHome
        self.outboundId = id
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "Outbound List"
        
        let label = UILabel()
        label.text = "Outbound List\nFrom Home: \(fromHome)\nID: \(outboundId)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

class AddSportsBriefsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "Add Sports Brief"
        
        let label = UILabel()
        label.text = "Add Sports Brief"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

class UpdatePasswordViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "Update Password"
        
        let label = UILabel()
        label.text = "Update Password"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

class ProfileViewViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "Profile View"
        
        let label = UILabel()
        label.text = "Profile View"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

class SearchStoriesViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "Search Stories"
        
        let label = UILabel()
        label.text = "Search Stories"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - MapViewController Extension
extension MapViewController {
    func configure(fromHome: Bool, id: Int) {
        // Configure map view controller with parameters
        // This would be implemented in your actual MapViewController
        print("Configuring MapViewController - fromHome: \(fromHome), id: \(id)")
    }
}
