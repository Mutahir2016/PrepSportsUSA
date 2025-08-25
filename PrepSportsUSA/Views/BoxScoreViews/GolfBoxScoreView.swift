//
//  GolfBoxScoreView.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import UIKit

extension GolfBoxScoreView {
    static func fromNib() -> GolfBoxScoreView? {
        let bundle = Bundle(for: GolfBoxScoreView.self)
        let nib = UINib(nibName: "GolfBoxScoreView", bundle: bundle)
        return nib.instantiate(withOwner: nil, options: nil).first as? GolfBoxScoreView
    }
}

class GolfBoxScoreView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var awayTeamLabel: UILabel!
    
    // Home team holes 1-9
    @IBOutlet weak var home1TextField: UITextField!
    @IBOutlet weak var home2TextField: UITextField!
    @IBOutlet weak var home3TextField: UITextField!
    @IBOutlet weak var home4TextField: UITextField!
    @IBOutlet weak var home5TextField: UITextField!
    @IBOutlet weak var home6TextField: UITextField!
    @IBOutlet weak var home7TextField: UITextField!
    @IBOutlet weak var home8TextField: UITextField!
    @IBOutlet weak var home9TextField: UITextField!
    @IBOutlet weak var homeOutLabel: UILabel!
    
    // Home team holes 10-18
    @IBOutlet weak var home10TextField: UITextField!
    @IBOutlet weak var home11TextField: UITextField!
    @IBOutlet weak var home12TextField: UITextField!
    @IBOutlet weak var home13TextField: UITextField!
    @IBOutlet weak var home14TextField: UITextField!
    @IBOutlet weak var home15TextField: UITextField!
    @IBOutlet weak var home16TextField: UITextField!
    @IBOutlet weak var home17TextField: UITextField!
    @IBOutlet weak var home18TextField: UITextField!
    @IBOutlet weak var homeInLabel: UILabel!
    @IBOutlet weak var homeTotalLabel: UILabel!
    
    // Away team holes 1-9
    @IBOutlet weak var away1TextField: UITextField!
    @IBOutlet weak var away2TextField: UITextField!
    @IBOutlet weak var away3TextField: UITextField!
    @IBOutlet weak var away4TextField: UITextField!
    @IBOutlet weak var away5TextField: UITextField!
    @IBOutlet weak var away6TextField: UITextField!
    @IBOutlet weak var away7TextField: UITextField!
    @IBOutlet weak var away8TextField: UITextField!
    @IBOutlet weak var away9TextField: UITextField!
    @IBOutlet weak var awayOutLabel: UILabel!
    
    // Away team holes 10-18
    @IBOutlet weak var away10TextField: UITextField!
    @IBOutlet weak var away11TextField: UITextField!
    @IBOutlet weak var away12TextField: UITextField!
    @IBOutlet weak var away13TextField: UITextField!
    @IBOutlet weak var away14TextField: UITextField!
    @IBOutlet weak var away15TextField: UITextField!
    @IBOutlet weak var away16TextField: UITextField!
    @IBOutlet weak var away17TextField: UITextField!
    @IBOutlet weak var away18TextField: UITextField!
    @IBOutlet weak var awayInLabel: UILabel!
    @IBOutlet weak var awayTotalLabel: UILabel!
    
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
        let homeTextFields = [home1TextField, home2TextField, home3TextField, home4TextField, home5TextField,
                             home6TextField, home7TextField, home8TextField, home9TextField, home10TextField,
                             home11TextField, home12TextField, home13TextField, home14TextField, home15TextField,
                             home16TextField, home17TextField, home18TextField]
        
        let awayTextFields = [away1TextField, away2TextField, away3TextField, away4TextField, away5TextField,
                             away6TextField, away7TextField, away8TextField, away9TextField, away10TextField,
                             away11TextField, away12TextField, away13TextField, away14TextField, away15TextField,
                             away16TextField, away17TextField, away18TextField]
        
        let allTextFields = homeTextFields + awayTextFields
        
        allTextFields.forEach { textField in
            textField?.layer.cornerRadius = 4
            textField?.layer.borderWidth = 1
            textField?.layer.borderColor = UIColor.systemGray5.cgColor
            textField?.textAlignment = .center
            textField?.keyboardType = .numberPad
            textField?.placeholder = "0"
        }
        
        // Setup total labels
        homeOutLabel.text = "0"
        homeInLabel.text = "0"
        homeTotalLabel.text = "0"
        awayOutLabel.text = "0"
        awayInLabel.text = "0"
        awayTotalLabel.text = "0"
        
        let totalLabels = [homeOutLabel, homeInLabel, homeTotalLabel, awayOutLabel, awayInLabel, awayTotalLabel]
        totalLabels.forEach { label in
            label?.font = UIFont.boldSystemFont(ofSize: 14)
        }
    }
    
    private func setupTextFieldTargets() {
        let homeTextFields = [home1TextField, home2TextField, home3TextField, home4TextField, home5TextField,
                             home6TextField, home7TextField, home8TextField, home9TextField, home10TextField,
                             home11TextField, home12TextField, home13TextField, home14TextField, home15TextField,
                             home16TextField, home17TextField, home18TextField]
        
        let awayTextFields = [away1TextField, away2TextField, away3TextField, away4TextField, away5TextField,
                             away6TextField, away7TextField, away8TextField, away9TextField, away10TextField,
                             away11TextField, away12TextField, away13TextField, away14TextField, away15TextField,
                             away16TextField, away17TextField, away18TextField]
        
        homeTextFields.forEach { textField in
            textField?.addTarget(self, action: #selector(homeTextFieldChanged), for: .editingChanged)
        }
        
        awayTextFields.forEach { textField in
            textField?.addTarget(self, action: #selector(awayTextFieldChanged), for: .editingChanged)
        }
    }
    
    @objc private func homeTextFieldChanged() {
        calculateTotals(isHome: true)
    }
    
    @objc private func awayTextFieldChanged() {
        calculateTotals(isHome: false)
    }
    
    private func calculateTotals(isHome: Bool) {
        if isHome {
            let outTextFields = [home1TextField, home2TextField, home3TextField, home4TextField, home5TextField,
                               home6TextField, home7TextField, home8TextField, home9TextField]
            let inTextFields = [home10TextField, home11TextField, home12TextField, home13TextField, home14TextField,
                              home15TextField, home16TextField, home17TextField, home18TextField]
            
            var outTotal = 0
            var inTotal = 0
            
            // Calculate OUT (holes 1-9)
            outTextFields.forEach { textField in
                let score = Int(textField?.text ?? "0") ?? 0
                outTotal += score
            }
            
            // Calculate IN (holes 10-18)
            inTextFields.forEach { textField in
                let score = Int(textField?.text ?? "0") ?? 0
                inTotal += score
            }
            
            let grandTotal = outTotal + inTotal
            
            homeOutLabel.text = "\(outTotal)"
            homeInLabel.text = "\(inTotal)"
            homeTotalLabel.text = "\(grandTotal)"
            
        } else {
            let outTextFields = [away1TextField, away2TextField, away3TextField, away4TextField, away5TextField,
                               away6TextField, away7TextField, away8TextField, away9TextField]
            let inTextFields = [away10TextField, away11TextField, away12TextField, away13TextField, away14TextField,
                              away15TextField, away16TextField, away17TextField, away18TextField]
            
            var outTotal = 0
            var inTotal = 0
            
            // Calculate OUT (holes 1-9)
            outTextFields.forEach { textField in
                let score = Int(textField?.text ?? "0") ?? 0
                outTotal += score
            }
            
            // Calculate IN (holes 10-18)
            inTextFields.forEach { textField in
                let score = Int(textField?.text ?? "0") ?? 0
                inTotal += score
            }
            
            let grandTotal = outTotal + inTotal
            
            awayOutLabel.text = "\(outTotal)"
            awayInLabel.text = "\(inTotal)"
            awayTotalLabel.text = "\(grandTotal)"
        }
    }
    
    func getBoxscoreData() -> GenericBoxscore {
        let homeTeamData: [String: AnyCodable] = [
            "one": AnyCodable(Int(home1TextField.text ?? "0") ?? 0),
            "two": AnyCodable(Int(home2TextField.text ?? "0") ?? 0),
            "three": AnyCodable(Int(home3TextField.text ?? "0") ?? 0),
            "four": AnyCodable(Int(home4TextField.text ?? "0") ?? 0),
            "five": AnyCodable(Int(home5TextField.text ?? "0") ?? 0),
            "six": AnyCodable(Int(home6TextField.text ?? "0") ?? 0),
            "seven": AnyCodable(Int(home7TextField.text ?? "0") ?? 0),
            "eight": AnyCodable(Int(home8TextField.text ?? "0") ?? 0),
            "nine": AnyCodable(Int(home9TextField.text ?? "0") ?? 0),
            "ten": AnyCodable(Int(home10TextField.text ?? "0") ?? 0),
            "eleven": AnyCodable(Int(home11TextField.text ?? "0") ?? 0),
            "twelve": AnyCodable(Int(home12TextField.text ?? "0") ?? 0),
            "thirteen": AnyCodable(Int(home13TextField.text ?? "0") ?? 0),
            "fourteen": AnyCodable(Int(home14TextField.text ?? "0") ?? 0),
            "fifteen": AnyCodable(Int(home15TextField.text ?? "0") ?? 0),
            "sixteen": AnyCodable(Int(home16TextField.text ?? "0") ?? 0),
            "seventeen": AnyCodable(Int(home17TextField.text ?? "0") ?? 0),
            "eighteen": AnyCodable(Int(home18TextField.text ?? "0") ?? 0),
            "OUT": AnyCodable(Int(homeOutLabel.text ?? "0") ?? 0),
            "IN": AnyCodable(Int(homeInLabel.text ?? "0") ?? 0),
            "TOT": AnyCodable(Int(homeTotalLabel.text ?? "0") ?? 0)
        ]
        
        let awayTeamData: [String: AnyCodable] = [
            "one": AnyCodable(Int(away1TextField.text ?? "0") ?? 0),
            "two": AnyCodable(Int(away2TextField.text ?? "0") ?? 0),
            "three": AnyCodable(Int(away3TextField.text ?? "0") ?? 0),
            "four": AnyCodable(Int(away4TextField.text ?? "0") ?? 0),
            "five": AnyCodable(Int(away5TextField.text ?? "0") ?? 0),
            "six": AnyCodable(Int(away6TextField.text ?? "0") ?? 0),
            "seven": AnyCodable(Int(away7TextField.text ?? "0") ?? 0),
            "eight": AnyCodable(Int(away8TextField.text ?? "0") ?? 0),
            "nine": AnyCodable(Int(away9TextField.text ?? "0") ?? 0),
            "ten": AnyCodable(Int(away10TextField.text ?? "0") ?? 0),
            "eleven": AnyCodable(Int(away11TextField.text ?? "0") ?? 0),
            "twelve": AnyCodable(Int(away12TextField.text ?? "0") ?? 0),
            "thirteen": AnyCodable(Int(away13TextField.text ?? "0") ?? 0),
            "fourteen": AnyCodable(Int(away14TextField.text ?? "0") ?? 0),
            "fifteen": AnyCodable(Int(away15TextField.text ?? "0") ?? 0),
            "sixteen": AnyCodable(Int(away16TextField.text ?? "0") ?? 0),
            "seventeen": AnyCodable(Int(away17TextField.text ?? "0") ?? 0),
            "eighteen": AnyCodable(Int(away18TextField.text ?? "0") ?? 0),
            "OUT": AnyCodable(Int(awayOutLabel.text ?? "0") ?? 0),
            "IN": AnyCodable(Int(awayInLabel.text ?? "0") ?? 0),
            "TOT": AnyCodable(Int(awayTotalLabel.text ?? "0") ?? 0)
        ]
        
        return GenericBoxscore(homeTeam: homeTeamData, awayTeam: awayTeamData)
    }
}
