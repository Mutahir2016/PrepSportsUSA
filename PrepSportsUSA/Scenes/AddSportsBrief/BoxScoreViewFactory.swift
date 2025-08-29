import SwiftUI
import UIKit

enum BoxScoreType {
    case golf
    case tennis
    case volleyball
}

class BoxScoreViewFactory {
    private let homeTeamName: String
    private let awayTeamName: String
    private let homeTeamImageURL: String?
    private let awayTeamImageURL: String?
    private let boxScoreType: BoxScoreType
    
    init(homeTeamName: String, awayTeamName: String, homeTeamImageURL: String?, awayTeamImageURL: String?, boxScoreType: BoxScoreType) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.homeTeamImageURL = homeTeamImageURL
        self.awayTeamImageURL = awayTeamImageURL
        self.boxScoreType = boxScoreType
    }
    
    func createGolfHostingController(homeScores: Binding<[Int]>, awayScores: Binding<[Int]>) -> UIHostingController<GolfBoxScoreView> {
        let golfView = GolfBoxScoreView(
            homeScores: homeScores,
            awayScores: awayScores,
            homeTeamName: homeTeamName,
            awayTeamName: awayTeamName,
            homeTeamImageURL: homeTeamImageURL,
            awayTeamImageURL: awayTeamImageURL
        )
        return UIHostingController(rootView: golfView)
    }
    
    func createTennisHostingController(homeScores: Binding<[Int]>, awayScores: Binding<[Int]>) -> UIHostingController<TennisBoxScoreView> {
        let tennisView = TennisBoxScoreView(
            homeScores: homeScores,
            awayScores: awayScores,
            homeTeamName: homeTeamName,
            awayTeamName: awayTeamName,
            homeTeamImageURL: homeTeamImageURL,
            awayTeamImageURL: awayTeamImageURL,
            isTennisScore: true
        )
        return UIHostingController(rootView: tennisView)
    }
    
    func createVolleyballHostingController(homeScores: Binding<[Int]>, awayScores: Binding<[Int]>) -> UIHostingController<TennisBoxScoreView> {
        let volleyballView = TennisBoxScoreView(
            homeScores: homeScores,
            awayScores: awayScores,
            homeTeamName: homeTeamName,
            awayTeamName: awayTeamName,
            homeTeamImageURL: homeTeamImageURL,
            awayTeamImageURL: awayTeamImageURL,
            isTennisScore: false
        )
        return UIHostingController(rootView: volleyballView)
    }
    

}
