//
//  GameSelectionTableViewCell.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 27/08/2025.
//

import UIKit

class GameSelectionTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "GameSelectionTableViewCell"
    
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
        
        // Venue label styling (main title)
        venueLabel.font = .ibmMedium(size: 16.0)
        venueLabel.textColor = UIColor.label
        venueLabel.numberOfLines = 0
        venueLabel.lineBreakMode = .byWordWrapping
        
        // Date/Time label styling (subtitle)
        dateTimeLabel.font = .ibmRegular(size: 14.0)
        dateTimeLabel.textColor = UIColor.secondaryLabel
        dateTimeLabel.numberOfLines = 1
    }
    
    // MARK: - Configuration
    func configure(with game: GameData, currentTeamId: String? = nil) {
        let homeTeamId = game.attributes.homeTeam.id
        let awayTeamId = game.attributes.awayTeam.id
        let homeTeamName = game.attributes.homeTeam.name
        let awayTeamName = game.attributes.awayTeam.name
        
        // Determine if the current team is home or away
        if let teamId = currentTeamId {
            if homeTeamId == teamId {
                // Current team is home, show away team with "vs"
                venueLabel.text = "vs \(awayTeamName)"
            } else if awayTeamId == teamId {
                // Current team is away, show home team with "@"
                venueLabel.text = "@ \(homeTeamName)"
            } else {
                // Fallback: show venue or home team
                let venue = game.attributes.venue ?? homeTeamName
                venueLabel.text = "@ \(venue)"
            }
        } else {
            // Fallback: show venue or home team
            let venue = game.attributes.venue ?? homeTeamName
            venueLabel.text = "@ \(venue)"
        }
        
        // Format date and time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let displayDateFormatter = DateFormatter()
        displayDateFormatter.dateFormat = "MMM. dd, yyyy"
        
        let displayTimeFormatter = DateFormatter()
        displayTimeFormatter.dateFormat = "@ h:mm a"
        
        var dateTimeString = ""
        if let date = dateFormatter.date(from: game.attributes.dateTime) {
            let dateString = displayDateFormatter.string(from: date)
            let timeString = displayTimeFormatter.string(from: date)
            dateTimeString = "\(dateString) \(timeString)"
        } else {
            dateTimeString = game.attributes.dateTime
        }
        
        dateTimeLabel.text = dateTimeString
    }
}
