//
//  SportsTableViewCell.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 22/08/2025.
//

import UIKit

class SportsTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var awayLabel: UILabel!
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var awayScoreLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "SportsTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Container view styling
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.masksToBounds = false
        
        // Background styling
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        // Title label styling
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor.label
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        // Subtitle label styling
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = UIColor.secondaryLabel
        
        // Home/Away labels styling
        homeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        homeLabel.textColor = UIColor.secondaryLabel
        homeLabel.text = "Home"
        
        awayLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        awayLabel.textColor = UIColor.secondaryLabel
        awayLabel.text = "Away"
        // Hide Home/Away captions to match design
        homeLabel.isHidden = true
        awayLabel.isHidden = true
        
        // Team labels styling
        homeTeamLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        homeTeamLabel.textColor = UIColor.label
        homeTeamLabel.text = "Home Team"
        homeTeamLabel.numberOfLines = 2
        homeTeamLabel.lineBreakMode = .byTruncatingTail
        
        awayTeamLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        awayTeamLabel.textColor = UIColor.label
        awayTeamLabel.text = "Away Team"
        awayTeamLabel.numberOfLines = 2
        awayTeamLabel.lineBreakMode = .byTruncatingTail

        // Ensure labels wrap instead of compressing into the center
        homeTeamLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        awayTeamLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        homeTeamLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        awayTeamLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        vsLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Constrain labels relative to the centered VS label to avoid overlap
        if homeTeamLabel.constraints.first(where: { $0.identifier == "home_vs_spacing" }) == nil {
            let c1 = homeTeamLabel.trailingAnchor.constraint(lessThanOrEqualTo: vsLabel.leadingAnchor, constant: -8)
            c1.identifier = "home_vs_spacing"
            c1.isActive = true
        }
        if awayTeamLabel.constraints.first(where: { $0.identifier == "away_vs_spacing" }) == nil {
            let c2 = awayTeamLabel.leadingAnchor.constraint(greaterThanOrEqualTo: vsLabel.trailingAnchor, constant: 8)
            c2.identifier = "away_vs_spacing"
            c2.isActive = true
        }
        
        // VS label styling
        vsLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        vsLabel.textColor = UIColor.secondaryLabel
        vsLabel.text = "vs"
        
        // Score labels styling
        homeScoreLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        homeScoreLabel.textColor = UIColor.systemBlue
        homeScoreLabel.text = "0"
        
        awayScoreLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        awayScoreLabel.textColor = UIColor.systemBlue
        awayScoreLabel.text = "0"
    }
    
    // MARK: - Configuration
    func configure(with matchData: SportsMatchData) {
        // Title: "Away vs Home - Sport" (Away shown on the left, Home on the right)
        let sportText = matchData.sport.isEmpty ? "" : " - \(matchData.sport)"
        titleLabel.text = "\(matchData.awayTeam) vs \(matchData.homeTeam)\(sportText)"
        
        // Subtitle: formatted date string if available
        subtitleLabel.text = matchData.dateTime ?? matchData.subtitle
        
        // Team names (Away on left, Home on right)
        homeTeamLabel.text = matchData.awayTeam
        awayTeamLabel.text = matchData.homeTeam
        
        // Scores (Away on left, Home on right)
        homeScoreLabel.text = "\(matchData.awayScore)"
        awayScoreLabel.text = "\(matchData.homeScore)"
    }
}

// MARK: - Data Model
struct SportsMatchData {
    let title: String
    let subtitle: String
    let homeTeam: String
    let awayTeam: String
    let homeScore: Int
    let awayScore: Int
    // Additional fields to render the card exactly like the design
    let sport: String
    let dateTime: String?
}
