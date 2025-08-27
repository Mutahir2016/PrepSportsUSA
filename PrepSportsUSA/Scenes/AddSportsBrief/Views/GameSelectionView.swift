//
//  GameSelectionView.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 27/08/2025.
//

import UIKit

class GameSelectionView: UIView {
    
    // MARK: - UI Elements
    private let containerView = UIView()
    private let venueLabel = UILabel()
    private let dateTimeLabel = UILabel()
    private let dropdownImageView = UIImageView()
    private let transparentButton = UIButton()
    
    // MARK: - Properties
    var onTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = UIColor.clear
        
        // Container view setup
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Venue label setup (main title)
        venueLabel.font = .ibmMedium(size: 16.0)
        venueLabel.textColor = UIColor.label
        venueLabel.numberOfLines = 1
        venueLabel.text = "Select Game"
        venueLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(venueLabel)
        
        // Date/Time label setup (subtitle)
        dateTimeLabel.font = .ibmRegular(size: 14.0)
        dateTimeLabel.textColor = UIColor.secondaryLabel
        dateTimeLabel.numberOfLines = 1
        dateTimeLabel.text = ""
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateTimeLabel)
        
        // Dropdown arrow image
        dropdownImageView.image = UIImage(systemName: "chevron.down")
        dropdownImageView.tintColor = UIColor.systemBlue
        dropdownImageView.contentMode = .scaleAspectFit
        dropdownImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dropdownImageView)
        
        // Transparent button for tap handling
        transparentButton.backgroundColor = UIColor.clear
        transparentButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        transparentButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(transparentButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            // Venue label constraints
            venueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            venueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            venueLabel.trailingAnchor.constraint(equalTo: dropdownImageView.leadingAnchor, constant: -8),
            
            // Date/Time label constraints
            dateTimeLabel.topAnchor.constraint(equalTo: venueLabel.bottomAnchor, constant: 4),
            dateTimeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dateTimeLabel.trailingAnchor.constraint(equalTo: dropdownImageView.leadingAnchor, constant: -8),
            dateTimeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // Dropdown image constraints
            dropdownImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            dropdownImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            dropdownImageView.widthAnchor.constraint(equalToConstant: 20),
            dropdownImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Transparent button constraints (covers entire container)
            transparentButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            transparentButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            transparentButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            transparentButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with game: GameData?) {
        if let game = game {
            let venue = game.attributes.venue ?? ""
            let homeTeamName = game.attributes.homeTeam.name
            let awayTeamName = game.attributes.awayTeam.name
            
            // Dynamic logic to determine if venue is a team name or actual venue:
            // 1. If venue matches either home or away team name exactly, it's a team
            // 2. If venue is similar to either team name (contains team name), it's a team
            // 3. Otherwise, it's an actual venue location
            
            let isTeamName = venue == homeTeamName || 
                            venue == awayTeamName ||
                            homeTeamName.contains(venue) || 
                            awayTeamName.contains(venue) ||
                            venue.contains(homeTeamName) ||
                            venue.contains(awayTeamName)
            
            if isTeamName {
                venueLabel.text = "vs \(venue)"
            } else {
                venueLabel.text = "@ \(venue)"
            }
            
            venueLabel.textColor = UIColor.label
            
            // Format date and time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            
            let displayDateFormatter = DateFormatter()
            displayDateFormatter.dateFormat = "MMM. dd, yyyy"
            
            let displayTimeFormatter = DateFormatter()
            displayTimeFormatter.dateFormat = "@ h:mm a"
            
            if let date = dateFormatter.date(from: game.attributes.dateTime) {
                let dateString = displayDateFormatter.string(from: date)
                let timeString = displayTimeFormatter.string(from: date)
                dateTimeLabel.text = "\(dateString) \(timeString)"
            } else {
                dateTimeLabel.text = game.attributes.dateTime
            }
            
        } else {
            venueLabel.text = "Select Game"
            venueLabel.textColor = UIColor.placeholderText
            dateTimeLabel.text = ""
        }
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        onTapped?()
    }
}
