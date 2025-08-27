import UIKit
import SwiftUI

enum BoxScoreType {
    case golf
    case tennis
    case volleyball
}

class BoxScoreViewFactory: UIViewController {
    
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
        // Don't set up the view here - let the parent handle it
    }
    
    func createHostingController() -> UIHostingController<AnyView> {
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
            
        case .tennis, .volleyball:
            let tennisView = TennisBoxScoreView(
                homeTeamName: homeTeamName,
                awayTeamName: awayTeamName,
                homeTeamImageURL: homeTeamImageURL,
                awayTeamImageURL: awayTeamImageURL,
                isTennisScore: boxScoreType == .tennis
            )
            boxScoreView = AnyView(tennisView)
        }
        
        let hostingController = UIHostingController(rootView: boxScoreView)
        return hostingController
    }
}
