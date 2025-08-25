//
//  VolleyballBoxScoreView.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import UIKit

extension VolleyballBoxScoreView {
    static func fromNib() -> VolleyballBoxScoreView? {
        let bundle = Bundle(for: VolleyballBoxScoreView.self)
        let nib = UINib(nibName: "VolleyballBoxScoreView", bundle: bundle)
        return nib.instantiate(withOwner: nil, options: nil).first as? VolleyballBoxScoreView
    }
}

class VolleyballBoxScoreView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var awayTeamLabel: UILabel!
    
    // Home team score fields
    @IBOutlet weak var homeSet1TextField: UITextField!
    @IBOutlet weak var homeSet2TextField: UITextField!
    @IBOutlet weak var homeSet3TextField: UITextField!
    @IBOutlet weak var homeSet4TextField: UITextField!
    @IBOutlet weak var homeSet5TextField: UITextField!
    @IBOutlet weak var homeFinalLabel: UILabel!
    
    // Away team score fields
    @IBOutlet weak var awaySet1TextField: UITextField!
    @IBOutlet weak var awaySet2TextField: UITextField!
    @IBOutlet weak var awaySet3TextField: UITextField!
    @IBOutlet weak var awaySet4TextField: UITextField!
    @IBOutlet weak var awaySet5TextField: UITextField!
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
        let textFields = [homeSet1TextField, homeSet2TextField, homeSet3TextField, homeSet4TextField, homeSet5TextField,
                         awaySet1TextField, awaySet2TextField, awaySet3TextField, awaySet4TextField, awaySet5TextField]
        
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
        let textFields = [homeSet1TextField, homeSet2TextField, homeSet3TextField, homeSet4TextField, homeSet5TextField,
                         awaySet1TextField, awaySet2TextField, awaySet3TextField, awaySet4TextField, awaySet5TextField]
        
        textFields.forEach { textField in
            textField?.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        }
    }
    
    @objc private func textFieldChanged() {
        calculateFinalScores()
    }
    
    private func calculateFinalScores() {
        let homeEditTexts = [homeSet1TextField, homeSet2TextField, homeSet3TextField, homeSet4TextField, homeSet5TextField]
        let awayEditTexts = [awaySet1TextField, awaySet2TextField, awaySet3TextField, awaySet4TextField, awaySet5TextField]
        
        var homeSetsWon = 0
        var awaySetsWon = 0
        
        for i in 0..<homeEditTexts.count {
            let homeScore = Int(homeEditTexts[i]?.text ?? "0") ?? 0
            let awayScore = Int(awayEditTexts[i]?.text ?? "0") ?? 0
            
            if homeScore > 0 || awayScore > 0 {
                if homeScore > awayScore {
                    homeSetsWon += 1
                } else if awayScore > homeScore {
                    awaySetsWon += 1
                }
            }
        }
        
        homeFinalLabel.text = "\(homeSetsWon)"
        awayFinalLabel.text = "\(awaySetsWon)"
    }
    
    func getBoxscoreData() -> GenericBoxscore {
        let homeTeamData: [String: AnyCodable] = [
            "first_set": AnyCodable(Int(homeSet1TextField.text ?? "0") ?? 0),
            "second_set": AnyCodable(Int(homeSet2TextField.text ?? "0") ?? 0),
            "third_set": AnyCodable(Int(homeSet3TextField.text ?? "0") ?? 0),
            "fourth_set": AnyCodable(Int(homeSet4TextField.text ?? "0") ?? 0),
            "fifth_set": AnyCodable(Int(homeSet5TextField.text ?? "0") ?? 0),
            "final_score": AnyCodable(Int(homeFinalLabel.text ?? "0") ?? 0)
        ]
        
        let awayTeamData: [String: AnyCodable] = [
            "first_set": AnyCodable(Int(awaySet1TextField.text ?? "0") ?? 0),
            "second_set": AnyCodable(Int(awaySet2TextField.text ?? "0") ?? 0),
            "third_set": AnyCodable(Int(awaySet3TextField.text ?? "0") ?? 0),
            "fourth_set": AnyCodable(Int(awaySet4TextField.text ?? "0") ?? 0),
            "fifth_set": AnyCodable(Int(awaySet5TextField.text ?? "0") ?? 0),
            "final_score": AnyCodable(Int(awayFinalLabel.text ?? "0") ?? 0)
        ]
        
        return GenericBoxscore(homeTeam: homeTeamData, awayTeam: awayTeamData)
    }
}
