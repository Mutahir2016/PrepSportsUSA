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
    @IBOutlet weak var quote1TextField: UITextField?
    @IBOutlet weak var quote2TextField: UITextField?
    @IBOutlet weak var quote3TextField: UITextField?
    @IBOutlet weak var quote4TextField: UITextField?
    @IBOutlet weak var quoteSourceTextField: UITextField?
    
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
    private var isUploading = false
    
    // Boxscore views for different sports
    private var currentBoxScoreView: UIView?
    private var footballBoxScoreView: FootballBoxScoreView?
    private var volleyballBoxScoreView: VolleyballBoxScoreView?
    private var tennisBoxScoreView: TennisBoxScoreView?
    private var golfBoxScoreView: GolfBoxScoreView?
    
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
        // Style school organization button
        schoolOrganizationButton.backgroundColor = UIColor.clear
        schoolOrganizationButton.layer.cornerRadius = 8
        schoolOrganizationButton.layer.borderWidth = 1
        schoolOrganizationButton.layer.borderColor = UIColor.systemGray4.cgColor
//        schoolOrganizationButton.contentHorizontalAlignment = .left
//        schoolOrganizationButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        schoolOrganizationButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        // Style team and game buttons similarly
        let dropdownButtons = [teamButton, gameButton]
        dropdownButtons.forEach { button in
            button?.backgroundColor = UIColor.clear
            button?.layer.cornerRadius = 8
            button?.layer.borderWidth = 1
            button?.layer.borderColor = UIColor.systemGray4.cgColor
//            button?.contentHorizontalAlignment = .left
//            button?.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            button?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        }
        
        // Add chevron icons to dropdown buttons
        addChevronToButton(schoolOrganizationButton)
        addChevronToButton(teamButton)
        addChevronToButton(gameButton)
        
        // Setup radio button styling
        setupRadioButtonStyling()
        
        // Style submit button
        submitButton.backgroundColor = UIColor.systemBlue
        submitButton.setTitleColor(UIColor.white, for: .normal)
        submitButton.layer.cornerRadius = 12
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    private func setupRadioButtonStyling() {
        // Style Boys button
        boysButton.backgroundColor = UIColor.clear
        boysButton.setTitleColor(UIColor.label, for: .normal)
        boysButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        boysButton.contentHorizontalAlignment = .left
//        boysButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        // Style Girls button
        girlsButton.backgroundColor = UIColor.clear
        girlsButton.setTitleColor(UIColor.label, for: .normal)
        girlsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        girlsButton.contentHorizontalAlignment = .left
//        girlsButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
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
        setupViewStyling()
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
    
    private func setupViewStyling() {
        // Set main background color to match Android design
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Style container views with white background and rounded corners
        let containerViews = [genderView, teamView, gameView, boxScoreView, descriptionView, imageUploadView, quotesView]
        
        containerViews.forEach { containerView in
            guard let container = containerView else { return }
            container.backgroundColor = UIColor.systemBackground
            container.layer.cornerRadius = 12
            container.layer.masksToBounds = true
            
            // Add subtle shadow for depth
            container.layer.shadowColor = UIColor.black.cgColor
            container.layer.shadowOffset = CGSize(width: 0, height: 1)
            container.layer.shadowRadius = 3
            container.layer.shadowOpacity = 0.1
            container.layer.masksToBounds = false
        }
        
        // Style school organization button container
        if let schoolOrgView = schoolOrganizationButton.superview {
            schoolOrgView.backgroundColor = UIColor.systemBackground
            schoolOrgView.layer.cornerRadius = 12
            schoolOrgView.layer.masksToBounds = true
            schoolOrgView.layer.shadowColor = UIColor.black.cgColor
            schoolOrgView.layer.shadowOffset = CGSize(width: 0, height: 1)
            schoolOrgView.layer.shadowRadius = 3
            schoolOrgView.layer.shadowOpacity = 0.1
            schoolOrgView.layer.masksToBounds = false
        }
    }
    
    private func setupActions() {
        schoolOrganizationButton.addTarget(self, action: #selector(schoolOrganizationButtonTapped), for: .touchUpInside)
        boysButton.addTarget(self, action: #selector(boysButtonTapped), for: .touchUpInside)
        girlsButton.addTarget(self, action: #selector(girlsButtonTapped), for: .touchUpInside)
        teamButton.addTarget(self, action: #selector(teamButtonTapped), for: .touchUpInside)
        gameButton.addTarget(self, action: #selector(gameButtonTapped), for: .touchUpInside)
        addImageButton.addTarget(self, action: #selector(addImageButtonTapped), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        
        // Setup ViewModel delegate
        viewModel.delegate = self
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
            boysRadioIcon.image = UIImage(systemName: "checkmark.circle.fill")
            boysRadioIcon.tintColor = UIColor.systemBlue
            girlsRadioIcon.image = UIImage(systemName: "circle")
            girlsRadioIcon.tintColor = UIColor.systemGray3
        } else if selectedGender == "Girls" {
            boysRadioIcon.image = UIImage(systemName: "circle")
            boysRadioIcon.tintColor = UIColor.systemGray3
            girlsRadioIcon.image = UIImage(systemName: "checkmark.circle.fill")
            girlsRadioIcon.tintColor = UIColor.systemBlue
        } else {
            // No selection
            boysRadioIcon.image = UIImage(systemName: "circle")
            boysRadioIcon.tintColor = UIColor.systemGray3
            girlsRadioIcon.image = UIImage(systemName: "circle")
            girlsRadioIcon.tintColor = UIColor.systemGray3
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
        guard let game = selectedGame,
              let team = selectedTeam else { return }
        
        let sport = team.attributes.sport.lowercased()
        setupBoxScoreForSport(sport, homeTeam: game.attributes.homeTeam.name, awayTeam: game.attributes.awayTeam.name)
    }
    
    private func setupBoxScoreForSport(_ sport: String, homeTeam: String, awayTeam: String) {
        // Remove current boxscore view if exists
        currentBoxScoreView?.removeFromSuperview()
        currentBoxScoreView = nil
        
        switch sport {
        case "football":
            setupFootballBoxScore(homeTeam: homeTeam, awayTeam: awayTeam)
        case "volleyball":
            setupVolleyballBoxScore(homeTeam: homeTeam, awayTeam: awayTeam)
        case "tennis":
            setupTennisBoxScore(homeTeam: homeTeam, awayTeam: awayTeam)
        case "golf":
            setupGolfBoxScore(homeTeam: homeTeam, awayTeam: awayTeam)
        default:
            setupUnsupportedSportView(sport: sport)
        }
    }
    
    private func setupFootballBoxScore(homeTeam: String, awayTeam: String) {
        footballBoxScoreView = FootballBoxScoreView.fromNib()
        guard let boxScoreView = footballBoxScoreView else { return }
        
        boxScoreView.homeTeamName = homeTeam
        boxScoreView.awayTeamName = awayTeam
        
        addBoxScoreViewToContainer(boxScoreView)
        currentBoxScoreView = boxScoreView
    }
    
    private func setupVolleyballBoxScore(homeTeam: String, awayTeam: String) {
        volleyballBoxScoreView = VolleyballBoxScoreView.fromNib()
        guard let boxScoreView = volleyballBoxScoreView else { return }
        
        boxScoreView.homeTeamName = homeTeam
        boxScoreView.awayTeamName = awayTeam
        
        addBoxScoreViewToContainer(boxScoreView)
        currentBoxScoreView = boxScoreView
    }
    
    private func setupTennisBoxScore(homeTeam: String, awayTeam: String) {
        tennisBoxScoreView = TennisBoxScoreView.fromNib()
        guard let boxScoreView = tennisBoxScoreView else { return }
        
        boxScoreView.homeTeamName = homeTeam
        boxScoreView.awayTeamName = awayTeam
        
        addBoxScoreViewToContainer(boxScoreView)
        currentBoxScoreView = boxScoreView
    }
    
    private func setupGolfBoxScore(homeTeam: String, awayTeam: String) {
        golfBoxScoreView = GolfBoxScoreView.fromNib()
        guard let boxScoreView = golfBoxScoreView else { return }
        
        boxScoreView.homeTeamName = homeTeam
        boxScoreView.awayTeamName = awayTeam
        
        addBoxScoreViewToContainer(boxScoreView)
        currentBoxScoreView = boxScoreView
    }
    
    private func setupUnsupportedSportView(sport: String) {
        let unsupportedView = UIView()
        unsupportedView.backgroundColor = UIColor.systemGray6
        unsupportedView.layer.cornerRadius = 12
        
        let messageLabel = UILabel()
        messageLabel.text = "Scoring for \(sport.capitalized) is not configured yet. Please contact support."
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = UIColor.systemRed
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        unsupportedView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: unsupportedView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: unsupportedView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: unsupportedView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: unsupportedView.trailingAnchor, constant: -16)
        ])
        
        addBoxScoreViewToContainer(unsupportedView)
        currentBoxScoreView = unsupportedView
    }
    
    private func addBoxScoreViewToContainer(_ view: UIView) {
        boxScoreView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: boxScoreView.topAnchor),
            view.leadingAnchor.constraint(equalTo: boxScoreView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: boxScoreView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: boxScoreView.bottomAnchor)
        ])
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
        guard selectedImages.count < maxImageCount else {
            showAlert(title: "Maximum Images", message: "You can only upload up to \(maxImageCount) images.")
            return
        }
        
        guard !isUploading else {
            showAlert(title: "Upload in Progress", message: "Please wait for the current image upload to complete.")
            return
        }
        
        presentImagePicker(sourceType: .photoLibrary)
    }
    
    @objc private func submitButtonTapped() {
        guard let organization = selectedOrganization,
              let gender = selectedGender,
              let team = selectedTeam,
              let game = selectedGame else {
            showAlert(title: "Missing Information", message: "Please complete all required selections.")
            return
        }
        
        let description = descriptionTextView.text ?? ""
        let quotes = getQuotesFromForm()
        let quoteSource = quoteSourceTextField?.text ?? ""
        
        let validation = viewModel.validatePrePitchInput(
            organization: organization,
            gender: gender,
            team: team,
            game: game,
            description: description,
            quotes: quotes,
            quoteSource: quoteSource
        )
        
        guard validation.isValid else {
            showAlert(title: "Validation Error", message: validation.errorMessage ?? "Please check your input.")
            return
        }
        
        // Create boxscore from inputs
        let boxscore = createBoxscoreFromInputs()
        
        // Submit the pre pitch
        viewModel.submitPrePitch(
            organizationId: organization.id,
            teamId: team.id,
            gameId: game.id,
            description: description,
            quotes: quotes,
            quoteSource: quoteSource,
            boxscore: boxscore
        )
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
    
    private func deleteImageTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < selectedImages.count else { return }
        
        selectedImages.remove(at: index)
        updateImageDisplay()
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
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


extension AddSportsBriefViewController {
    // MARK: - Helper Methods
    private func getQuotesFromForm() -> [String] {
        var quotes: [String] = []
        
        let quote1 = quote1TextField?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let quote2 = quote2TextField?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let quote3 = quote3TextField?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let quote4 = quote4TextField?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        if !quote1.isEmpty { quotes.append(quote1) }
        if !quote2.isEmpty { quotes.append(quote2) }
        if !quote3.isEmpty { quotes.append(quote3) }
        if !quote4.isEmpty { quotes.append(quote4) }
        
        return quotes
    }
    
    private func createBoxscoreFromInputs() -> GenericBoxscore {
        // Get boxscore data based on current sport
        if let footballView = footballBoxScoreView {
            return footballView.getBoxscoreData()
        } else if let volleyballView = volleyballBoxScoreView {
            return volleyballView.getBoxscoreData()
        } else if let tennisView = tennisBoxScoreView {
            return tennisView.getBoxscoreData()
        } else if let golfView = golfBoxScoreView {
            return golfView.getBoxscoreData()
        } else {
            // Fallback to empty boxscore
            let emptyData: [String: AnyCodable] = [:]
            return GenericBoxscore(homeTeam: emptyData, awayTeam: emptyData)
        }
    }
    
    private func generateImageFilename() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        return "sports_brief_\(timestamp).jpg"
    }
    
    private func showImageCaptionDialog(for uploadedImage: UploadedImage, at index: Int) {
        let alert = UIAlertController(title: "Image Details", message: "Add caption and credit for this image", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Caption"
            textField.text = uploadedImage.caption
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Credit"
            textField.text = uploadedImage.credit
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            let caption = alert.textFields?[0].text ?? ""
            let credit = alert.textFields?[1].text ?? ""
            self?.viewModel.updateImageCaption(at: index, caption: caption, credit: credit)
        })
        
        alert.addAction(UIAlertAction(title: "Skip", style: .cancel))
        
        present(alert, animated: true)
    }
}
    
    
// MARK: - AddSportsBriefViewModelDelegate
extension AddSportsBriefViewController: AddSportsBriefViewModelDelegate {
    func briefSubmittedSuccessfully() {
        DispatchQueue.main.async {
            self.showAlert(title: "Success", message: "Sports Brief submitted successfully!") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func briefSubmissionFailed(error: String) {
        DispatchQueue.main.async {
            self.showAlert(title: "Submission Failed", message: error)
        }
    }
    
    func imageUploadProgress(progress: Float) {
        DispatchQueue.main.async {
            // Update progress indicator if needed
            print("Image upload progress: \(progress * 100)%")
        }
    }
    
    func imageUploadCompleted(uploadedImage: UploadedImage) {
        DispatchQueue.main.async {
            self.isUploading = false
            self.updateImageDisplay()
            
            // Show dialog to add caption and credit
            let index = self.viewModel.getUploadedImages().count - 1
            self.showImageCaptionDialog(for: uploadedImage, at: index)
        }
    }
    
    func imageUploadFailed(error: String) {
        DispatchQueue.main.async {
            self.isUploading = false
            self.showAlert(title: "Upload Failed", message: error)
        }
    }
}
    
    // MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension AddSportsBriefViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let editedImage = info[.editedImage] as? UIImage {
            isUploading = true
            selectedImages.append(editedImage)
            updateImageDisplay()
            
            // Upload image to server
            let filename = generateImageFilename()
            viewModel.uploadImage(editedImage, filename: filename)
            
        } else if let originalImage = info[.originalImage] as? UIImage {
            isUploading = true
            selectedImages.append(originalImage)
            updateImageDisplay()
            
            // Upload image to server
            let filename = generateImageFilename()
            viewModel.uploadImage(originalImage, filename: filename)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
