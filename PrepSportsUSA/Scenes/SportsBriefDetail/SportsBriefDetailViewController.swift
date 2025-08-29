//
//  SportsBriefDetailViewController.swift
//  PrepSportsUSA
//
//  Created by Cascade on 30/08/2025.
//

import UIKit
import RxSwift
import RxCocoa

final class SportsBriefDetailViewController: BaseViewController {
    var viewModel: SportsBriefDetailViewModel!
    var router: SportsBriefDetailRouter!
    
    // IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    // Game Information IBOutlets
    @IBOutlet weak var awayTeamLogo: UIImageView!
    @IBOutlet weak var awayTeamNameGame: UILabel!
    @IBOutlet weak var homeTeamLogo: UIImageView!
    @IBOutlet weak var homeTeamNameGame: UILabel!
    @IBOutlet weak var gameDateTimeLabel: UILabel!
    @IBOutlet weak var gameVenueLabel: UILabel!
    
    // Media IBOutlets
    @IBOutlet weak var mediaCard: UIView!
    @IBOutlet weak var mediaItem1: UIView!
    @IBOutlet weak var mediaItem2: UIView!
    @IBOutlet weak var mediaItem3: UIView!
    @IBOutlet weak var mediaImage1: UIImageView!
    @IBOutlet weak var mediaImage2: UIImageView!
    @IBOutlet weak var mediaImage3: UIImageView!
    
    // Quotes IBOutlets
    @IBOutlet weak var quotesCard: UIView!
    @IBOutlet weak var quoteSourceLabel: UILabel!
    @IBOutlet weak var quote1Label: UILabel!
    @IBOutlet weak var quote2Label: UILabel!
    @IBOutlet weak var quote3Label: UILabel!
    @IBOutlet weak var quote4Label: UILabel!
    
    // Boxscore IBOutlets
    @IBOutlet weak var boxscoreCard: UIView!
    @IBOutlet weak var homeTeamStatsStack: UIStackView!
    @IBOutlet weak var awayTeamStatsStack: UIStackView!
    
    override func callingInsideViewDidLoad() {
        setupNav()
        setupMediaTapGestures()
        bindVM()
        viewModel.fetch()
    }
    
    override func setUp() {
        
    }
    private func setupNav() {
        title = "Sports Brief"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func bindVM() {
        viewModel.detailRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                let attrs = data.attributes
                self.titleLabel.text = formattedTitle(from: attrs)
                self.dateLabel.text = self.formatDate(attrs.payload?.limparGame?.dateTime)
                
                // Team info
                let team = attrs.payload?.limparTeam
                self.teamNameLabel.text = team?.name ?? "-"
                self.schoolLabel.text = "School: \(team?.schoolName ?? "-")"
                self.sportLabel.text = "Sport: \(team?.sport?.capitalized ?? "-")"
                self.genderLabel.text = "Gender: \(team?.sex?.capitalized ?? "-")"
                self.nicknameLabel.text = "Nickname: \(team?.teamNickname ?? "-")"
                
                // Description
                self.descriptionText.text = attrs.description ?? "—"
                
                // Game Information
                let game = attrs.payload?.limparGame
                self.gameDateTimeLabel.text = self.formatDate(game?.dateTime) ?? "—"
                self.gameVenueLabel.text = game?.venue ?? "—"
                
                // Team names for game section (away = left, home = right)
                if let awayTeam = game?.awayTeam {
                    self.awayTeamNameGame.text = awayTeam.name
                    self.loadTeamLogo(from: awayTeam.image?.url, into: self.awayTeamLogo)
                }
                
                if let homeTeam = game?.homeTeam {
                    self.homeTeamNameGame.text = homeTeam.name
                    self.loadTeamLogo(from: homeTeam.image?.url, into: self.homeTeamLogo)
                }
                
                // Media section
                self.setupMediaSection(with: attrs.media)
                
                // Quotes section
                self.setupQuotesSection(with: attrs.quotes, source: attrs.payload?.quoteSource)
                
                // Boxscore section
                self.setupBoxscoreSection(with: attrs.payload?.boxscore)
            })
            .disposed(by: disposeBag)
        
        viewModel.sessionExpiredRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showSessionExpiredAlert()
            })
            .disposed(by: disposeBag)
    }
    
    private func showSessionExpiredAlert() {
        let alert = UIAlertController(title: "Session Expired", message: "Please login again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.router.logoutAndNavigateToSignIn()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func loadTeamLogo(from urlString: String?, into imageView: UIImageView) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            // Set placeholder image if no URL
            imageView.image = UIImage(systemName: "sportscourt.circle")
            imageView.tintColor = .systemGray3
            return
        }
        
        // Simple image loading with URLSession
        URLSession.shared.dataTask(with: url) { [weak imageView] data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                DispatchQueue.main.async {
                    imageView?.image = UIImage(systemName: "sportscourt.circle")
                    imageView?.tintColor = .systemGray3
                }
                return
            }
            
            DispatchQueue.main.async {
                imageView?.image = image
                imageView?.contentMode = .scaleAspectFit
            }
        }.resume()
    }
    
    private func setupMediaTapGestures() {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(mediaImage1Tapped))
        mediaImage1.addGestureRecognizer(tap1)
        mediaImage1.isUserInteractionEnabled = true
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(mediaImage2Tapped))
        mediaImage2.addGestureRecognizer(tap2)
        mediaImage2.isUserInteractionEnabled = true
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(mediaImage3Tapped))
        mediaImage3.addGestureRecognizer(tap3)
        mediaImage3.isUserInteractionEnabled = true
    }
    
    @objc private func mediaImage1Tapped() {
        showFullScreenImage(mediaImage1.image)
    }
    
    @objc private func mediaImage2Tapped() {
        showFullScreenImage(mediaImage2.image)
    }
    
    @objc private func mediaImage3Tapped() {
        showFullScreenImage(mediaImage3.image)
    }
    
    private func setupMediaSection(with media: [PrePitchMedia]?) {
        guard let media = media, !media.isEmpty else {
            mediaCard.isHidden = true
            return
        }
        
        mediaCard.isHidden = false
        let mediaItems = [mediaItem1, mediaItem2, mediaItem3]
        let mediaImages = [mediaImage1, mediaImage2, mediaImage3]
        
        // Show up to 3 media items
        for (index, mediaItem) in media.prefix(3).enumerated() {
            mediaItems[index]?.isHidden = false
            if let imageView = mediaImages[index] {
                loadMediaImage(from: mediaItem.url, into: imageView)
            }
        }
        
        // Hide unused media items
        for index in media.count..<3 {
            mediaItems[index]?.isHidden = true
        }
    }
    
    private func loadMediaImage(from urlString: String?, into imageView: UIImageView) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .systemGray3
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak imageView] data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                DispatchQueue.main.async {
                    imageView?.image = UIImage(systemName: "photo")
                    imageView?.tintColor = .systemGray3
                }
                return
            }
            
            DispatchQueue.main.async {
                imageView?.image = image
                imageView?.contentMode = .scaleAspectFill
            }
        }.resume()
    }
    
    private func showFullScreenImage(_ image: UIImage?) {
        guard let image = image else { return }
        
        let fullScreenVC = UIViewController()
        fullScreenVC.view.backgroundColor = .black
        fullScreenVC.modalPresentationStyle = .fullScreen
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        fullScreenVC.view.addSubview(imageView)
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        closeButton.layer.cornerRadius = 20
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeFullScreenImage), for: .touchUpInside)
        fullScreenVC.view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: fullScreenVC.view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: fullScreenVC.view.centerYAnchor),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: fullScreenVC.view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: fullScreenVC.view.trailingAnchor, constant: -20),
            imageView.topAnchor.constraint(greaterThanOrEqualTo: fullScreenVC.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: fullScreenVC.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: fullScreenVC.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: fullScreenVC.view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        present(fullScreenVC, animated: true)
    }
    
    @objc private func closeFullScreenImage() {
        dismiss(animated: true)
    }
    
    private func setupQuotesSection(with quotes: [String]?, source: String?) {
        guard let quotes = quotes, !quotes.isEmpty else {
            quotesCard.isHidden = true
            return
        }
        
        quotesCard.isHidden = false
        
        // Set quote source
        if let source = source, !source.isEmpty {
            quoteSourceLabel.text = "Source: \(source)"
        } else {
            quoteSourceLabel.text = "Source: —"
        }
        
        // Set up to 4 quotes
        let quoteLabels = [quote1Label, quote2Label, quote3Label, quote4Label]
        
        for (index, quote) in quotes.prefix(4).enumerated() {
            if let label = quoteLabels[index] {
                label.text = "\"\(quote)\""
                label.isHidden = false
            }
        }
        
        // Hide unused quote labels
        for index in min(quotes.count, 4)..<4 {
            quoteLabels[index]?.isHidden = true
        }
    }
    
    private func setupBoxscoreSection(with boxscore: Boxscore?) {
        guard let boxscore = boxscore else {
            boxscoreCard.isHidden = true
            return
        }
        
        boxscoreCard.isHidden = false
        
        // Setup home team stats
        setupTeamStats(boxscore.homeTeam, in: homeTeamStatsStack)
        
        // Setup away team stats
        setupTeamStats(boxscore.awayTeam, in: awayTeamStatsStack)
    }
    
    private func setupTeamStats(_ teamStats: [String: AnyCodable]?, in stackView: UIStackView) {
        // Clear existing arranged subviews
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let teamStats = teamStats else { return }
        
        // Sort keys with custom logic for sports statistics
        let sortedKeys = teamStats.keys.sorted { key1, key2 in
            return customStatOrder(key1) < customStatOrder(key2)
        }
        
        for key in sortedKeys {
            let value = teamStats[key]
            let statView = createStatView(title: formatStatTitle(key), value: formatStatValue(value))
            stackView.addArrangedSubview(statView)
        }
    }
    
    private func createStatView(title: String, value: String) -> UIView {
        let containerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor(white: 0.33, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.textColor = UIColor(white: 0.33, alpha: 1.0)
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -8),
            
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            containerView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return containerView
    }
    
    private func formatStatTitle(_ key: String) -> String {
        // Convert snake_case or camelCase to readable format
        let formatted = key.replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
        return formatted.capitalized + ":"
    }
    
    private func formatStatValue(_ value: AnyCodable?) -> String {
        guard let value = value else { return "—" }
        
        if let intValue = value.value as? Int {
            return "\(intValue)"
        } else if let stringValue = value.value as? String {
            return stringValue
        } else if let doubleValue = value.value as? Double {
            return String(format: "%.1f", doubleValue)
        } else {
            return "\(value.value)"
        }
    }
    
    private func customStatOrder(_ key: String) -> Int {
        let lowercaseKey = key.lowercased()
        
        // Define priority order for common sports statistics
        let priorityOrder: [String: Int] = [
            // Sets (Tennis, Volleyball, etc.)
            "first_set": 1,
            "firstset": 1,
            "first set": 1,
            "set_1": 1,
            "set1": 1,
            
            "second_set": 2,
            "secondset": 2,
            "second set": 2,
            "set_2": 2,
            "set2": 2,
            
            "third_set": 3,
            "thirdset": 3,
            "third set": 3,
            "set_3": 3,
            "set3": 3,
            
            "fourth_set": 4,
            "fourthset": 4,
            "fourth set": 4,
            "set_4": 4,
            "set4": 4,
            
            "fifth_set": 5,
            "fifthset": 5,
            "fifth set": 5,
            "set_5": 5,
            "set5": 5,
            
            // Periods/Quarters (Basketball, Football, etc.)
            "first_quarter": 10,
            "firstquarter": 10,
            "first quarter": 10,
            "q1": 10,
            "quarter_1": 10,
            
            "second_quarter": 11,
            "secondquarter": 11,
            "second quarter": 11,
            "q2": 11,
            "quarter_2": 11,
            
            "third_quarter": 12,
            "thirdquarter": 12,
            "third quarter": 12,
            "q3": 12,
            "quarter_3": 12,
            
            "fourth_quarter": 13,
            "fourthquarter": 13,
            "fourth quarter": 13,
            "q4": 13,
            "quarter_4": 13,
            
            // Innings (Baseball)
            "inning_1": 20,
            "inning_2": 21,
            "inning_3": 22,
            "inning_4": 23,
            "inning_5": 24,
            "inning_6": 25,
            "inning_7": 26,
            "inning_8": 27,
            "inning_9": 28,
            
            // Golf Holes (1-18)
            "one": 30,
            "hole_1": 30,
            "hole1": 30,
            
            "two": 31,
            "hole_2": 31,
            "hole2": 31,
            
            "three": 32,
            "hole_3": 32,
            "hole3": 32,
            
            "four": 33,
            "hole_4": 33,
            "hole4": 33,
            
            "five": 34,
            "hole_5": 34,
            "hole5": 34,
            
            "six": 35,
            "hole_6": 35,
            "hole6": 35,
            
            "seven": 36,
            "hole_7": 36,
            "hole7": 36,
            
            "eight": 37,
            "hole_8": 37,
            "hole8": 37,
            
            "nine": 38,
            "hole_9": 38,
            "hole9": 38,
            
            "out": 39, // Front 9 total
            
            "ten": 40,
            "hole_10": 40,
            "hole10": 40,
            
            "eleven": 41,
            "hole_11": 41,
            "hole11": 41,
            
            "twelve": 42,
            "hole_12": 42,
            "hole12": 42,
            
            "thirteen": 43,
            "hole_13": 43,
            "hole13": 43,
            
            "fourteen": 44,
            "hole_14": 44,
            "hole14": 44,
            
            "fifteen": 45,
            "hole_15": 45,
            "hole15": 45,
            
            "sixteen": 46,
            "hole_16": 46,
            "hole16": 46,
            
            "seventeen": 47,
            "hole_17": 47,
            "hole17": 47,
            
            "eighteen": 48,
            "hole_18": 48,
            "hole18": 48,
            
            "in": 49, // Back 9 total
            
            // Golf totals
            "tot": 1000,
            "total": 1000,
            
            // Final scores should come last
            "final_score": 1001,
            "finalscore": 1001,
            "final score": 1001,
            "final": 1001
        ]
        
        // Check for exact matches first
        if let priority = priorityOrder[lowercaseKey] {
            return priority
        }
        
        // Check for partial matches (e.g., keys containing "first", "second", etc.)
        for (pattern, priority) in priorityOrder {
            if lowercaseKey.contains(pattern) {
                return priority
            }
        }
        
        // Extract numbers from keys for generic ordering (e.g., "period_3" -> 3)
        let numbers = lowercaseKey.compactMap { $0.wholeNumberValue }
        if let firstNumber = numbers.first {
            return 100 + firstNumber // Put numbered items in middle range
        }
        
        // Default: alphabetical order for unknown keys (high priority to put at end)
        return 2000 + lowercaseKey.hashValue % 1000
    }
    
    private func makeInfo(_ title: String, _ value: String?) -> NSAttributedString {
        let bold = NSAttributedString(string: "\(title): ", attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
        let normal = NSAttributedString(string: value ?? "-", attributes: [.font: UIFont.systemFont(ofSize: 14)])
        let m = NSMutableAttributedString(attributedString: bold)
        m.append(normal)
        return m
    }
    
    private func formattedTitle(from attrs: PrePitchAttributes) -> String {
        let away = attrs.payload?.limparGame?.awayTeam?.name ?? ""
        let home = attrs.payload?.limparGame?.homeTeam?.name ?? ""
        let sport = (attrs.payload?.limparTeam?.sport ?? "").capitalized
        let firstLine = "\(away) vs \(home)"
        return sport.isEmpty ? firstLine : firstLine + " - \(sport)"
    }
    
    private func formatDate(_ iso: String?) -> String? {
        guard let iso = iso, !iso.isEmpty else { return nil }
        let iso1 = ISO8601DateFormatter()
        iso1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var d = iso1.date(from: iso)
        if d == nil {
            let iso2 = ISO8601DateFormatter()
            iso2.formatOptions = [.withInternetDateTime]
            d = iso2.date(from: iso)
        }
        guard let date = d else { return nil }
        let out = DateFormatter()
        out.locale = Locale(identifier: "en_US_POSIX")
        out.dateFormat = "MMM d, yyyy @ h:mma"
        return out.string(from: date).replacingOccurrences(of: "AM", with: "am").replacingOccurrences(of: "PM", with: "pm")
    }
}
