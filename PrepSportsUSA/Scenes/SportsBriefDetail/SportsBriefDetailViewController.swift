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
    
    override func callingInsideViewDidLoad() {
        setupNav()
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
