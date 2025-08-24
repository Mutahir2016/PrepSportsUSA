//
//  AddSportsBriefViewController.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import UIKit
import RxSwift
import RxCocoa

class AddSportsBriefViewController: BaseViewController {
    var viewModel: AddSportsBriefViewModel!
    var router: AddSportsBriefRouter!
    
    @IBOutlet weak var schoolOrganizationButton: UIButton!
    @IBOutlet weak var boysButton: UIButton!
    @IBOutlet weak var girlsButton: UIButton!
    @IBOutlet weak var boysRadioIcon: UIImageView!
    @IBOutlet weak var girlsRadioIcon: UIImageView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var teamButton: UIButton!
    @IBOutlet weak var teamView: UIView!
    @IBOutlet weak var gameButton: UIButton!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var boxScoreView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var imageUploadView: UIView!
    @IBOutlet weak var imageUploadLabel: UILabel!
    @IBOutlet weak var imageThumbnailsStackView: UIStackView!
    @IBOutlet weak var thumbnailImageView1: UIImageView!
    @IBOutlet weak var thumbnailImageView2: UIImageView!
    @IBOutlet weak var thumbnailImageView3: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var quotesView: UIView!
    @IBOutlet weak var quotesLabel: UILabel!
    @IBOutlet weak var quotesStackView: UIStackView!
    @IBOutlet weak var quote1TextField: UITextField!
    @IBOutlet weak var quote2TextField: UITextField!
    @IBOutlet weak var quote3TextField: UITextField!
    @IBOutlet weak var quote4TextField: UITextField!
    
    // Box Score Text Fields
    @IBOutlet weak var homeQ1TextField: UITextField!
    @IBOutlet weak var homeQ2TextField: UITextField!
    @IBOutlet weak var homeQ3TextField: UITextField!
    @IBOutlet weak var homeQ4TextField: UITextField!
    @IBOutlet weak var homeOTTextField: UITextField!
    @IBOutlet weak var homeFinalLabel: UILabel!
    @IBOutlet weak var awayQ1TextField: UITextField!
    @IBOutlet weak var awayQ2TextField: UITextField!
    @IBOutlet weak var awayQ3TextField: UITextField!
    @IBOutlet weak var awayQ4TextField: UITextField!
    @IBOutlet weak var awayOTTextField: UITextField!
    @IBOutlet weak var awayFinalLabel: UILabel!
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var awayTeamLabel: UILabel!
    
    // MARK: - Private Properties
    private var selectedOrganization: SchoolOrganizationData?
    private var selectedGender: String?
    private var selectedTeam: TeamData?
    private var selectedGame: GameData?
    private var selectedImages: [UIImage] = []
    private let maxImageCount = 3
    
    override func callingInsideViewDidLoad() {
        setupViewModelAndRouter()
        setupUI()
        setupInitialVisibility()
        setupActions()
    }
    
    private func setupInitialVisibility() {
        // Hide all sections initially except school organization
        genderView.isHidden = true
        teamView.isHidden = true
        gameView.isHidden = true
        boxScoreView.isHidden = true
        descriptionView.isHidden = true
        submitButton.isHidden = true
        imageUploadView.isHidden = true
        quotesView.isHidden = true
    }
    
    
    private func setupButtonAppearances() {
        // Add chevron icons to dropdown buttons
        addChevronToButton(schoolOrganizationButton)
        addChevronToButton(teamButton)
        addChevronToButton(gameButton)
        
        // Setup radio button icons
        boysRadioIcon.image = UIImage(systemName: "circle")
        boysRadioIcon.tintColor = UIColor.systemGray3
        girlsRadioIcon.image = UIImage(systemName: "circle")
        girlsRadioIcon.tintColor = UIColor.systemGray3
    }
    
    private func addChevronToButton(_ button: UIButton) {
        let chevronImage = UIImage(systemName: "chevron.down")
        button.setImage(chevronImage, for: .normal)
        button.tintColor = UIColor.systemGray3
        button.semanticContentAttribute = .forceRightToLeft
        
        // Use a dispatch queue to ensure layout has occurred before adjusting insets
        DispatchQueue.main.async {
            let imageWidth = chevronImage?.size.width ?? 0
            let textWidth = button.titleLabel?.frame.size.width ?? 0
            let spacing: CGFloat = 8
            
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: textWidth + spacing, bottom: 0, right: -(textWidth + spacing))
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageWidth + spacing), bottom: 0, right: imageWidth + spacing)
        }
    }
    
    
    override func setUp() {
        
    }
    
    private func setupViewModelAndRouter() {
        viewModel = AddSportsBriefViewModel()
        router = AddSportsBriefRouter(self)
    }
    
    private func setupUI() {
        title = "Add Sports Brief"
        setupButtonAppearances()
        updateSchoolOrganizationButton()
        updateGenderViewVisibility()
        updateGenderSelection()
        updateTeamViewVisibility()
        updateTeamButton()
        updateGameViewVisibility()
        updateGameButton()
        updateBoxScoreViewVisibility()
        setupDescriptionTextView()
        updateImageDisplay()
    }
    
    private func setupActions() {
        schoolOrganizationButton.addTarget(self, action: #selector(schoolOrganizationButtonTapped), for: .touchUpInside)
        boysButton.addTarget(self, action: #selector(boysButtonTapped), for: .touchUpInside)
        girlsButton.addTarget(self, action: #selector(girlsButtonTapped), for: .touchUpInside)
        teamButton.addTarget(self, action: #selector(teamButtonTapped), for: .touchUpInside)
        gameButton.addTarget(self, action: #selector(gameButtonTapped), for: .touchUpInside)
        addImageButton.addTarget(self, action: #selector(addImageButtonTapped), for: .touchUpInside)
    }
    
    @objc private func schoolOrganizationButtonTapped() {
        router.navigateToSelectSchoolOrganization()
    }
    
    @objc private func boysButtonTapped() {
        selectedGender = "Boys"
        selectedTeam = nil // Reset team when gender changes
        selectedGame = nil // Reset game when gender changes
        updateGenderSelection()
        updateTeamViewVisibility()
        updateTeamButton()
        updateGameViewVisibility()
        updateGameButton()
    }
    
    @objc private func girlsButtonTapped() {
        selectedGender = "Girls"
        selectedTeam = nil // Reset team when gender changes
        selectedGame = nil // Reset game when gender changes
        updateGenderSelection()
        updateTeamViewVisibility()
        updateTeamButton()
        updateGameViewVisibility()
        updateGameButton()
    }
    
    @objc private func teamButtonTapped() {
        guard let organization = selectedOrganization,
              let gender = selectedGender else {
            print("Missing organization or gender for team selection")
            return
        }
        
        // Convert gender to API format
        let apiGender = gender == "Boys" ? "Men" : "Women"
        router.navigateToSelectTeam(organizationId: organization.id, sex: apiGender)
    }
    
    @objc private func gameButtonTapped() {
        guard let team = selectedTeam else {
            print("Missing team for game selection")
            return
        }
        
        router.navigateToSelectGame(teamId: team.id)
    }
    
    func didSelectSchoolOrganization(_ school: SchoolOrganizationData) {
        selectedOrganization = school
        updateSchoolOrganizationButton()
        updateGenderViewVisibility()
        // Reset gender and team when organization changes
        selectedGender = nil
        selectedTeam = nil
        updateGenderSelection()
        updateTeamViewVisibility()
        updateTeamButton()
    }
    
    private func updateSchoolOrganizationButton() {
        if let school = selectedOrganization {
            schoolOrganizationButton.setTitle(school.attributes.name, for: .normal)
            schoolOrganizationButton.setTitleColor(UIColor.label, for: .normal)
        } else {
            schoolOrganizationButton.setTitle("Select School Organization", for: .normal)
            schoolOrganizationButton.setTitleColor(UIColor.placeholderText, for: .normal)
        }
    }
    
    private func updateGenderViewVisibility() {
        // Show gender view only if a school organization is selected
        genderView.isHidden = selectedOrganization == nil
    }
    
    private func updateGenderSelection() {
        // Update radio button appearances
        if selectedGender == "Boys" {
            boysRadioIcon.image = UIImage(systemName: "largecircle.fill.circle")
            boysRadioIcon.tintColor = UIColor.blue
            girlsRadioIcon.image = UIImage(systemName: "circle")
            girlsRadioIcon.tintColor = UIColor.lightGray
        } else if selectedGender == "Girls" {
            boysRadioIcon.image = UIImage(systemName: "circle")
            boysRadioIcon.tintColor = UIColor.lightGray
            girlsRadioIcon.image = UIImage(systemName: "largecircle.fill.circle")
            girlsRadioIcon.tintColor = UIColor.blue
        } else {
            // No selection
            boysRadioIcon.image = UIImage(systemName: "circle")
            boysRadioIcon.tintColor = UIColor.lightGray
            girlsRadioIcon.image = UIImage(systemName: "circle")
            girlsRadioIcon.tintColor = UIColor.lightGray
        }
    }
    
    private func updateTeamViewVisibility() {
        // Show team view only if a gender is selected
        teamView.isHidden = selectedGender == nil
    }
    
    func didSelectTeam(_ team: TeamData) {
        selectedTeam = team
        selectedGame = nil // Reset game selection when team changes
        updateTeamButton()
        updateGameViewVisibility()
        updateGameButton()
        updateBoxScoreViewVisibility()
    }
    
    func didSelectGame(_ game: GameData) {
        selectedGame = game
        updateGameButton()
        updateBoxScoreDisplay()
    }
    
    private func updateTeamButton() {
        if let team = selectedTeam {
            teamButton.setTitle(team.attributes.name, for: .normal)
            teamButton.setTitleColor(UIColor.label, for: .normal)
        } else {
            teamButton.setTitle("Select Team", for: .normal)
            teamButton.setTitleColor(UIColor.placeholderText, for: .normal)
        }
    }
    
    private func updateGameViewVisibility() {
        // Show game view only if a team is selected
        gameView.isHidden = selectedTeam == nil
    }
    
    private func updateGameButton() {
        if let game = selectedGame {
            let homeTeam = game.attributes.homeTeam.name
            let awayTeam = game.attributes.awayTeam.name
            gameButton.setTitle("\(homeTeam) vs \(awayTeam)", for: .normal)
            gameButton.setTitleColor(UIColor.label, for: .normal)
            updateBoxScoreViewVisibility()
        } else {
            gameButton.setTitle("Select Game", for: .normal)
            gameButton.setTitleColor(UIColor.placeholderText, for: .normal)
            updateBoxScoreViewVisibility()
        }
    }
    
    private func updateBoxScoreViewVisibility() {
        // Show box score only if a game is selected
        boxScoreView.isHidden = selectedGame == nil
        descriptionView.isHidden = selectedGame == nil
        imageUploadView.isHidden = selectedGame == nil
        quotesView.isHidden = selectedGame == nil
        submitButton.isHidden = selectedGame == nil
    }
    
    private func updateBoxScoreDisplay() {
        guard let game = selectedGame else { return }
        
        // Update team labels
        homeTeamLabel.text = game.attributes.homeTeam.name
        awayTeamLabel.text = game.attributes.awayTeam.name
        
        // Setup text field delegates for auto-calculation
        setupBoxScoreTextFields()
    }
    
    private func setupBoxScoreTextFields() {
        let textFields = [homeQ1TextField, homeQ2TextField, homeQ3TextField, homeQ4TextField, homeOTTextField,
                         awayQ1TextField, awayQ2TextField, awayQ3TextField, awayQ4TextField, awayOTTextField]
        
        textFields.forEach { textField in
            textField?.addTarget(self, action: #selector(boxScoreTextFieldChanged), for: .editingChanged)
        }
    }
    
    private func clearScoreFields() {
        // Box score functionality not implemented in current UI
        // This method can be removed since we don't have score text fields in the storyboard
    }
    
    @objc private func boxScoreTextFieldChanged() {
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
    
    
    private func setupDescriptionTextView() {
        descriptionTextView.delegate = self
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.borderWidth = 1
    }
    
    @objc private func addImageButtonTapped() {
        presentImagePicker(sourceType: .photoLibrary)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            showAlert(title: "Not Available", message: "This source is not available on this device.")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    private func updateImageDisplay() {
        let imageViews = [thumbnailImageView1, thumbnailImageView2, thumbnailImageView3]
        
        for (index, imageView) in imageViews.enumerated() {
            if index < selectedImages.count {
                imageView?.image = selectedImages[index]
                imageView?.isHidden = false
            } else {
                imageView?.image = nil
                imageView?.isHidden = true
            }
        }
        
        // Hide/show add image button if max images reached
        addImageButton.isHidden = selectedImages.count >= maxImageCount
    }
    
    @objc private func deleteImageTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < selectedImages.count else { return }
        
        selectedImages.remove(at: index)
        updateImageDisplay()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddSportsBriefViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Score text fields not implemented in current UI
        // This validation can be removed since we don't have score text fields in the storyboard
        return true
    }
}

// MARK: - UITextViewDelegate
extension AddSportsBriefViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.placeholderText {
            textView.text = ""
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter description (max 1000 characters)"
            textView.textColor = UIColor.placeholderText
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 1000
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension AddSportsBriefViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImages.append(editedImage)
            updateImageDisplay()
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImages.append(originalImage)
            updateImageDisplay()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
