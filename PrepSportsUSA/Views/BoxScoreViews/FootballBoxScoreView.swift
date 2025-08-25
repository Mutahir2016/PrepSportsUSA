//
//  FootballBoxScoreView.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import UIKit

extension FootballBoxScoreView {
    static func fromNib() -> FootballBoxScoreView? {
        let bundle = Bundle(for: FootballBoxScoreView.self)
        let nib = UINib(nibName: "FootballBoxScoreView", bundle: bundle)
        return nib.instantiate(withOwner: nil, options: nil).first as? FootballBoxScoreView
    }
}

class FootballBoxScoreView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var awayTeamLabel: UILabel!
    
    // Home team score fields
    @IBOutlet weak var homeQ1TextField: UITextField!
    @IBOutlet weak var homeQ2TextField: UITextField!
    @IBOutlet weak var homeQ3TextField: UITextField!
    @IBOutlet weak var homeQ4TextField: UITextField!
    @IBOutlet weak var homeOTTextField: UITextField!
    @IBOutlet weak var homeFinalLabel: UILabel!
    
    // Away team score fields
    @IBOutlet weak var awayQ1TextField: UITextField!
    @IBOutlet weak var awayQ2TextField: UITextField!
    @IBOutlet weak var awayQ3TextField: UITextField!
    @IBOutlet weak var awayQ4TextField: UITextField!
    @IBOutlet weak var awayOTTextField: UITextField!
    @IBOutlet weak var awayFinalLabel: UILabel!
    
    // MARK: - Properties
    var homeTeamName: String = "" {
        didSet {
            homeTeamLabel.text = homeTeamName
        }
    }
    
    var awayTeamName: String = "" {
        didSet {
            awayTeamLabel.text = awayTeamName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupTextFieldTargets()
    }
    
    private func setupUI() {
        // Style the view
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        backgroundColor = UIColor.systemBackground
        
        // Setup text fields
        let textFields = [homeQ1TextField, homeQ2TextField, homeQ3TextField, homeQ4TextField, homeOTTextField,
                         awayQ1TextField, awayQ2TextField, awayQ3TextField, awayQ4TextField, awayOTTextField]
        
        textFields.forEach { textField in
            textField?.layer.cornerRadius = 4
            textField?.layer.borderWidth = 1
            textField?.layer.borderColor = UIColor.systemGray5.cgColor
            textField?.textAlignment = .center
            textField?.keyboardType = .numberPad
            textField?.placeholder = "0"
        }
        
        // Setup final labels
        homeFinalLabel.text = "0"
        awayFinalLabel.text = "0"
        homeFinalLabel.font = UIFont.boldSystemFont(ofSize: 16)
        awayFinalLabel.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    private func setupTextFieldTargets() {
        let textFields = [homeQ1TextField, homeQ2TextField, homeQ3TextField, homeQ4TextField, homeOTTextField,
                         awayQ1TextField, awayQ2TextField, awayQ3TextField, awayQ4TextField, awayOTTextField]
        
        textFields.forEach { textField in
            textField?.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        }
    }
    
    @objc private func textFieldChanged() {
        calculateFinalScores()
    }
    
    private func calculateFinalScores() {
        // Calculate home team final score
        let homeQ1 = Int(homeQ1TextField.text ?? "0") ?? 0
        let homeQ2 = Int(homeQ2TextField.text ?? "0") ?? 0
        let homeQ3 = Int(homeQ3TextField.text ?? "0") ?? 0
        let homeQ4 = Int(homeQ4TextField.text ?? "0") ?? 0
        let homeOT = Int(homeOTTextField.text ?? "0") ?? 0
        let homeFinal = homeQ1 + homeQ2 + homeQ3 + homeQ4 + homeOT
        homeFinalLabel.text = "\(homeFinal)"
        
        // Calculate away team final score
        let awayQ1 = Int(awayQ1TextField.text ?? "0") ?? 0
        let awayQ2 = Int(awayQ2TextField.text ?? "0") ?? 0
        let awayQ3 = Int(awayQ3TextField.text ?? "0") ?? 0
        let awayQ4 = Int(awayQ4TextField.text ?? "0") ?? 0
        let awayOT = Int(awayOTTextField.text ?? "0") ?? 0
        let awayFinal = awayQ1 + awayQ2 + awayQ3 + awayQ4 + awayOT
        awayFinalLabel.text = "\(awayFinal)"
    }
    
    func getBoxscoreData() -> GenericBoxscore {
        let homeTeamData: [String: AnyCodable] = [
            "first_quarter": AnyCodable(homeQ1TextField.text?.isEmpty == false ? homeQ1TextField.text! : "0"),
            "second_quarter": AnyCodable(homeQ2TextField.text?.isEmpty == false ? homeQ2TextField.text! : "0"),
            "third_quarter": AnyCodable(homeQ3TextField.text?.isEmpty == false ? homeQ3TextField.text! : "0"),
            "fourth_quarter": AnyCodable(homeQ4TextField.text?.isEmpty == false ? homeQ4TextField.text! : "0"),
            "overtime": AnyCodable([homeOTTextField.text?.isEmpty == false ? homeOTTextField.text! : "0"]),
            "final": AnyCodable(homeFinalLabel.text ?? "0")
        ]
        
        let awayTeamData: [String: AnyCodable] = [
            "first_quarter": AnyCodable(awayQ1TextField.text?.isEmpty == false ? awayQ1TextField.text! : "0"),
            "second_quarter": AnyCodable(awayQ2TextField.text?.isEmpty == false ? awayQ2TextField.text! : "0"),
            "third_quarter": AnyCodable(awayQ3TextField.text?.isEmpty == false ? awayQ3TextField.text! : "0"),
            "fourth_quarter": AnyCodable(awayQ4TextField.text?.isEmpty == false ? awayQ4TextField.text! : "0"),
            "overtime": AnyCodable([awayOTTextField.text?.isEmpty == false ? awayOTTextField.text! : "0"]),
            "final": AnyCodable(awayFinalLabel.text ?? "0")
        ]
        
        return GenericBoxscore(homeTeam: homeTeamData, awayTeam: awayTeamData)
    }
}
