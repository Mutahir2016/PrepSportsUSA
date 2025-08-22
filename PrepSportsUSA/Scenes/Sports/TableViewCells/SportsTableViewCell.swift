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
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
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
        
        // Team labels styling
        homeTeamLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        homeTeamLabel.textColor = UIColor.label
        homeTeamLabel.text = "Home Team"
        
        awayTeamLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        awayTeamLabel.textColor = UIColor.label
        awayTeamLabel.text = "Away Team"
        
        // VS label styling
        vsLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        vsLabel.textColor = UIColor.secondaryLabel
        vsLabel.text = "VS"
        
        // Score labels styling
        homeScoreLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        homeScoreLabel.textColor = UIColor.systemBlue
        homeScoreLabel.text = "0"
        
        awayScoreLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        awayScoreLabel.textColor = UIColor.systemBlue
        awayScoreLabel.text = "0"
    }
    
    // MARK: - Configuration
    func configure(with matchData: SportsMatchData) {
        titleLabel.text = matchData.title
        subtitleLabel.text = matchData.subtitle
        homeTeamLabel.text = "Home Team"
        awayTeamLabel.text = "Away Team"
        homeScoreLabel.text = "\(matchData.homeScore)"
        awayScoreLabel.text = "\(matchData.awayScore)"
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
}
