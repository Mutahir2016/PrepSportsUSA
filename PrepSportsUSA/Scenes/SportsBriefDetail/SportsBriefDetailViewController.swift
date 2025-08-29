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
