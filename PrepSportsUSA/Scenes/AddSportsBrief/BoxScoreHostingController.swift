import UIKit
import SwiftUI

enum BoxScoreType {
    case golf
    case tennis
}

class BoxScoreHostingController: UIViewController {
    
    let homeTeamName: String
    let awayTeamName: String
    let homeTeamImageURL: String?
    let awayTeamImageURL: String?
    let boxScoreType: BoxScoreType
    
    init(homeTeamName: String, awayTeamName: String, homeTeamImageURL: String?, awayTeamImageURL: String?, boxScoreType: BoxScoreType) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.homeTeamImageURL = homeTeamImageURL
        self.awayTeamImageURL = awayTeamImageURL
        self.boxScoreType = boxScoreType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        let boxScoreView: AnyView
        
        // Create the appropriate SwiftUI view based on sport type
        switch boxScoreType {
        case .golf:
            let golfView = GolfBoxScoreView(
                homeTeamName: homeTeamName,
                awayTeamName: awayTeamName,
                homeTeamImageURL: homeTeamImageURL,
                awayTeamImageURL: awayTeamImageURL
            )
            boxScoreView = AnyView(golfView)
            
        case .tennis:
            let tennisView = TennisBoxScoreView(
                homeTeamName: homeTeamName,
                awayTeamName: awayTeamName,
                homeTeamImageURL: homeTeamImageURL,
                awayTeamImageURL: awayTeamImageURL
            )
            boxScoreView = AnyView(tennisView)
        }
        
        let hostingController = UIHostingController(rootView: boxScoreView)
        
        // Set the hosting controller's view background to white to preserve the card appearance
        hostingController.view.backgroundColor = .white
        
        // Add the hosting controller as a child
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Set up constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
