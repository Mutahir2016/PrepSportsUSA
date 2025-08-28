//
//  AddSportsBriefViewController.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage

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
    @IBOutlet weak var gameTitleView: UIView!
    
    // Programmatically created views
    private var gameView: UIView!
    private var gameSelectionView: GameSelectionView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var boxScoreView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var boxScoreContentView: UIView!
    
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

    // Quote Source Section
    @IBOutlet weak var quoteSourceView: UIView!
    @IBOutlet weak var quoteSourceTextField: UITextField!

    // Box Score Text Fields
    @IBOutlet weak var homeIcon: UIImageView!
    @IBOutlet weak var awayIcon: UIImageView!
    @IBOutlet weak var homeScoreIcon: UIImageView!
    @IBOutlet weak var awayScoreIcon: UIImageView!

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
    private var isAdmin = false

    // Box Score SwiftUI Integration
    private var boxScoreFactory: BoxScoreViewFactory?
    private var swiftUIBoxScoreView: UIView?

    // Remove complex boxscore view properties - we'll use the storyboard elements

    override func callingInsideViewDidLoad() {
        setupViewModelAndRouter()
        setupUI()
        setupInitialVisibility()
        setupActions()

        // Check if user is admin
        let accType = RKStorage.shared.getUserProfile()?.data.attributes.accountType ?? ""
        if accType.lowercased() == "admin" || accType.lowercased() == "sysadmin" {
            print("is Admin or SysAdmin")
            isAdmin = true
            // For admin and sysadmin users, keep button enabled and fetch selected schools
            viewModel.fetchSelectedSchools()
        } else {
            print("is not Admin")
            isAdmin = false
            // For non-admin users, disable the organization button and fetch selected schools
            schoolOrganizationButton.isEnabled = false
            schoolOrganizationButton.alpha = 0.6
            viewModel.fetchSelectedSchools()
        }
    }

    private func setupInitialVisibility() {
        // Hide all sections initially except school organization
        genderView.isHidden = true
        teamView.isHidden = true
        gameView.isHidden = true
        boxScoreView.isHidden = true
        swiftUIBoxScoreView?.isHidden = true
        descriptionView.isHidden = true
        submitButton.isHidden = true
        imageUploadView.isHidden = true
        quotesView.isHidden = true
        quoteSourceView.isHidden = true
    }


    private func setupButtonAppearances() {
        // Simple button styling - just basic appearance
        schoolOrganizationButton.backgroundColor = UIColor.white
        schoolOrganizationButton.layer.cornerRadius = 8
        schoolOrganizationButton.layer.borderWidth = 1
        schoolOrganizationButton.layer.borderColor = UIColor.systemGray4.cgColor
        schoolOrganizationButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        // Style team button
        teamButton.backgroundColor = UIColor.white
        teamButton.layer.cornerRadius = 8
        teamButton.layer.borderWidth = 1
        teamButton.layer.borderColor = UIColor.systemGray4.cgColor
        teamButton.setTitleColor(UIColor.placeholderText, for: .normal)
        teamButton.contentHorizontalAlignment = .left
        teamButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        teamButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        // Setup custom game selection view
        setupGameSelectionView()
        
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
        boysButton.backgroundColor = UIColor.white
        boysButton.setTitleColor(UIColor.label, for: .normal)
        boysButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)

        // Style Girls button
        girlsButton.backgroundColor = UIColor.white
        girlsButton.setTitleColor(UIColor.label, for: .normal)
        girlsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)

        // Setup radio button icons
        boysRadioIcon.image = UIImage(systemName: "circle")
        boysRadioIcon.tintColor = UIColor.systemGray3
        girlsRadioIcon.image = UIImage(systemName: "circle")
        girlsRadioIcon.tintColor = UIColor.systemGray3
    }

    private func setupRadioButtonTapGestures() {
        // Enable user interaction for radio button images
        boysRadioIcon.isUserInteractionEnabled = true
        girlsRadioIcon.isUserInteractionEnabled = true

        // Add tap gesture recognizers to radio button images
        let boysTapGesture = UITapGestureRecognizer(target: self, action: #selector(boysRadioIconTapped))
        boysRadioIcon.addGestureRecognizer(boysTapGesture)

        let girlsTapGesture = UITapGestureRecognizer(target: self, action: #selector(girlsRadioIconTapped))
        girlsRadioIcon.addGestureRecognizer(girlsTapGesture)
    }
    
    private func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func addChevronToButton(_ button: UIButton) {
        let chevronImage = UIImage(systemName: "chevron.down")
        button.setImage(chevronImage, for: .normal)
        button.tintColor = UIColor.systemGray

        // Use semantic content attribute to position chevron on right
        button.semanticContentAttribute = .forceRightToLeft

        // Set content edge insets to add padding
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        // Add spacing between text and image (chevron)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)

        // Ensure text alignment is left
        button.contentHorizontalAlignment = .left
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
        setupBoxScoreTextFields()
        updateSchoolOrganizationButton()
        updateGenderViewVisibility()
        updateGenderSelection()
        updateTeamViewVisibility()
        updateTeamButton()
        updateGameViewVisibility()
        updateGameButtonDisplay()
        setupDescriptionTextView()
        updateImageDisplay()
    }

    private func setupActions() {
        schoolOrganizationButton.addTarget(self, action: #selector(schoolOrganizationButtonTapped), for: .touchUpInside)
        boysButton.addTarget(self, action: #selector(boysButtonTapped), for: .touchUpInside)
        girlsButton.addTarget(self, action: #selector(girlsButtonTapped), for: .touchUpInside)
        teamButton.addTarget(self, action: #selector(teamButtonTapped), for: .touchUpInside)
        addImageButton.addTarget(self, action: #selector(addImageButtonTapped), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)

        // Add tap gestures to radio button images
        setupRadioButtonTapGestures()
        
        // Add tap gesture to dismiss keyboard
        setupTapToDismissKeyboard()

        // Setup ViewModel delegate
        viewModel.delegate = self
    }

    @objc private func schoolOrganizationButtonTapped() {
        // Allow navigation for admin and sysadmin users
        if isAdmin {
            router.navigateToSelectSchoolOrganization()
        }
        // Non-admin users cannot tap this button (it's disabled)
    }

    @objc private func boysButtonTapped() {
        selectedGender = "Boys"
        selectedTeam = nil // Reset team when gender changes
        selectedGame = nil // Reset game when gender changes
        updateGenderSelection()
        updateTeamViewVisibility()
        updateTeamButton()
        updateGameViewVisibility()
        updateGameButtonDisplay()
    }

    @objc private func girlsButtonTapped() {
        selectedGender = "Girls"
        selectedTeam = nil // Reset team when gender changes
        selectedGame = nil // Reset game when gender changes
        updateGenderSelection()
        updateTeamViewVisibility()
        updateTeamButton()
        updateGameViewVisibility()
        updateGameButtonDisplay()
    }

    @objc private func boysRadioIconTapped() {
        // Same functionality as boys button tap
        boysButtonTapped()
    }

    @objc private func girlsRadioIconTapped() {
        // Same functionality as girls button tap
        girlsButtonTapped()
    }

    @objc private func teamButtonTapped() {
        guard let organization = selectedOrganization else {
            print("Missing organization or gender for team selection")
            return
        }

        // Use Boys/Girls format consistently with SelectTeamViewController
        let genderForAPI = selectedGender ?? ""
        router.navigateToSelectTeam(organizationId: organization.id, sex: genderForAPI)
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
        genderView.isHidden = true
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
        teamView.isHidden = selectedOrganization == nil
    }

    func didSelectTeam(_ team: TeamData) {
        selectedTeam = team
        selectedGame = nil // Reset game selection when team changes
        updateTeamButton()
        updateGameViewVisibility()
        updateGameButtonDisplay()
    }

    func didSelectGame(_ game: GameData) {
        selectedGame = game
        updateGameButtonDisplay()
        updateBoxScoreDisplay()
    }

    private func updateTeamButton() {
        if let team = selectedTeam {
            let teamTitle = "\(team.attributes.sport) (\(team.attributes.displaySex))"
            teamButton.setTitle(teamTitle, for: .normal)
            teamButton.setTitleColor(UIColor.label, for: .normal)
        } else {
            teamButton.setTitle("Select Team", for: .normal)
            teamButton.setTitleColor(UIColor.placeholderText, for: .normal)
        }
    }

    private func updateGameViewVisibility() {
        // Show game view only if a team is selected
        gameTitleView.isHidden = selectedTeam == nil
        gameView?.isHidden = selectedTeam == nil
    }

    private func addGameViewToStackView() {
        // Find the main stack view and add gameView after gameTitleView
        guard let mainStackView = findMainStackView() else {
            print("Could not find main stack view")
            return
        }
        
        // Find the index of gameTitleView
        if let gameTitleIndex = mainStackView.arrangedSubviews.firstIndex(of: gameTitleView) {
            mainStackView.insertArrangedSubview(gameView, at: gameTitleIndex + 1)
            // Reduce spacing between game title and game view
            mainStackView.setCustomSpacing(8, after: gameTitleView)
        } else {
            // Fallback: add at the end
            mainStackView.addArrangedSubview(gameView)
        }
    }
    
    private func findMainStackView() -> UIStackView? {
        // Navigate through the view hierarchy to find the main stack view
        // Based on the storyboard structure: ScrollView -> ContentView -> StackView
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView,
           let contentView = scrollView.subviews.first,
           let stackView = contentView.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
            return stackView
        }
        return nil
    }
    
    private func updateGameButtonDisplay() {
        let currentTeamId = selectedTeam?.id
        gameSelectionView.configure(with: selectedGame, currentTeamId: currentTeamId)
        updateBoxScoreViewVisibility()
    }
    
    private func setupGameSelectionView() {
        // Create game container view
        gameView = UIView()
        gameView.backgroundColor = UIColor.clear
        gameView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create game selection view
        gameSelectionView = GameSelectionView()
        gameSelectionView.translatesAutoresizingMaskIntoConstraints = false
        gameView.addSubview(gameSelectionView)
        
        NSLayoutConstraint.activate([
            gameSelectionView.topAnchor.constraint(equalTo: gameView.topAnchor),
            gameSelectionView.leadingAnchor.constraint(equalTo: gameView.leadingAnchor),
            gameSelectionView.trailingAnchor.constraint(equalTo: gameView.trailingAnchor),
            gameSelectionView.bottomAnchor.constraint(equalTo: gameView.bottomAnchor),
            gameView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
        
        gameSelectionView.onTapped = { [weak self] in
            self?.gameButtonTapped()
        }
        
        // Add gameView to the main stack view after gameTitleView
        addGameViewToStackView()
    }

    private func updateBoxScoreViewVisibility() {
        guard let game = selectedGame else {
            // Hide all views if no game is selected
            boxScoreView.isHidden = true
            boxScoreView?.isHidden = true
            descriptionView.isHidden = true
            imageUploadView.isHidden = true
            quotesView.isHidden = true
            quoteSourceView.isHidden = true
            submitButton.isHidden = true
            swiftUIBoxScoreView = nil
            return
        }

        // Show appropriate box score view based on sport
        if let team = selectedTeam {
            let sport = team.attributes.sport.lowercased()
            if sport == "football" {
                // Show football box score, clean up SwiftUI views
                boxScoreView.isHidden = false
                cleanupSwiftUIViews()
                // Show the storyboard football content
                showFootballBoxScoreContent(true)

            } else if sport == "golf" || sport == "tennis" || sport == "volleyball" {
                // Keep boxScoreView visible but show SwiftUI content inside it
                boxScoreView.isHidden = false
                // Hide the storyboard football content for SwiftUI sports
                showFootballBoxScoreContent(false)
                // Always recreate SwiftUI view when game changes to update with new data
                cleanupSwiftUIViews()
                setupBoxScoreView()
                // Show the SwiftUI box score view
                swiftUIBoxScoreView?.isHidden = false
            } else if sport == "soccer" {
                // Show soccer not configured message
                boxScoreView.isHidden = false
                cleanupSwiftUIViews()
                showFootballBoxScoreContent(true)
            } else {
                boxScoreView.isHidden = false
                cleanupSwiftUIViews()
                showFootballBoxScoreContent(true)
            }
        }

        // Show other views
        descriptionView.isHidden = false
        imageUploadView.isHidden = false
        quotesView.isHidden = false
        quoteSourceView.isHidden = false
        submitButton.isHidden = false
    }

    private func updateBoxScoreDisplay() {
        guard let game = selectedGame,
              let team = selectedTeam else { return }

        // Update team names in the storyboard labels
        homeTeamLabel.text = game.attributes.homeTeam.name
        awayTeamLabel.text = game.attributes.awayTeam.name

        homeIcon.sd_setImage(with: URL(string: game.attributes.homeTeam.image?.url ?? ""), placeholderImage: UIImage(named: "placeholder"))
        awayIcon.sd_setImage(with: URL(string: game.attributes.awayTeam.image?.url ?? ""), placeholderImage: UIImage(named: "placeholder"))
        
        // Set the same team icons for the score rows
        homeScoreIcon.sd_setImage(with: URL(string: game.attributes.homeTeam.image?.url ?? ""), placeholderImage: UIImage(named: "placeholder"))
        awayScoreIcon.sd_setImage(with: URL(string: game.attributes.awayTeam.image?.url ?? ""), placeholderImage: UIImage(named: "placeholder"))
        // Clear all score fields
        clearScoreFields()
    }

    // Remove complex sport-specific setup methods - we'll use the storyboard football box score

    private func setupBoxScoreTextFields() {
        let textFields = [homeQ1TextField, homeQ2TextField, homeQ3TextField, homeQ4TextField, homeOTTextField,
                          awayQ1TextField, awayQ2TextField, awayQ3TextField, awayQ4TextField, awayOTTextField]

        textFields.forEach { textField in
            textField?.addTarget(self, action: #selector(boxScoreTextFieldChanged), for: .editingChanged)
            textField?.placeholder = "0"
            textField?.text = ""
        }
    }

    private func setupBoxScoreView() {
        guard let game = selectedGame,
              let team = selectedTeam else {
            return
        }

        let sport = team.attributes.sport.lowercased()
        let boxScoreType: BoxScoreType

        // TODO: - make volleyball separate
        if sport == "golf" {
            boxScoreType = .golf
        } else if sport == "tennis" {
            boxScoreType = .tennis
        } else if sport == "volleyball" {
            boxScoreType = .volleyball
        } else {
            boxScoreType = .golf
        }

        // Create the unified box score view factory
        boxScoreFactory = BoxScoreViewFactory(
            homeTeamName: game.attributes.homeTeam.name,
            awayTeamName: game.attributes.awayTeam.name,
            homeTeamImageURL: game.attributes.homeTeam.image?.url,
            awayTeamImageURL: game.attributes.awayTeam.image?.url,
            boxScoreType: boxScoreType
        )

        // Create and add the hosting controller directly
        if let controller = boxScoreFactory {
            let hostingController = controller.createHostingController()
            
            // Add the hosting controller as a child
            addChild(hostingController)
            boxScoreContentView.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)

            // Set up constraints to fill the boxScoreView completely
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: boxScoreContentView.topAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: boxScoreContentView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: boxScoreContentView.trailingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: boxScoreContentView.bottomAnchor)
            ])
            
            // Store the view reference
            swiftUIBoxScoreView = hostingController.view
        }
    }

    private func cleanupSwiftUIViews() {
        // Remove SwiftUI view from parent if it exists
        if let swiftUIView = swiftUIBoxScoreView {
            swiftUIView.removeFromSuperview()
            swiftUIBoxScoreView = nil
        }

        // Remove all child view controllers
        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        // Remove any custom message views (like soccer message)
        boxScoreContentView.subviews.forEach { subview in
            if subview != swiftUIBoxScoreView {
                subview.removeFromSuperview()
            }
        }
        
        boxScoreFactory = nil
    }

    private func showFootballBoxScoreContent(_ show: Bool) {
        // Find all the football-specific UI elements in the storyboard and hide/show them
        if let boxScoreStackView = boxScoreView.subviews.first(where: { $0 is UIStackView }) {
            boxScoreStackView.isHidden = !show
        }
    }

    private func clearScoreFields() {
        // Clear all score text fields to show placeholder
        let textFields = [homeQ1TextField, homeQ2TextField, homeQ3TextField, homeQ4TextField, homeOTTextField,
                          awayQ1TextField, awayQ2TextField, awayQ3TextField, awayQ4TextField, awayOTTextField]

        textFields.forEach { textField in
            textField?.text = ""
            textField?.placeholder = "0"
        }

        // Clear final score labels
        homeFinalLabel.text = "0"
        awayFinalLabel.text = "0"
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

        // Set placeholder text
        descriptionTextView.text = "Enter description (max 1000 characters)"
        descriptionTextView.textColor = UIColor.placeholderText
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
              let team = selectedTeam,
              let game = selectedGame else {
            showAlert(title: "Missing Information", message: "Please complete all required selections.")
            return
        }

        let description = descriptionTextView.text ?? ""

        // Validate description is not empty and not placeholder text
        if description.isEmpty || description == "Enter description (max 1000 characters)" || descriptionTextView.textColor == UIColor.placeholderText {
            showAlert(title: "Missing Description", message: "Please enter a description for the sports brief.")
            return
        }

        let quotes = getQuotesFromForm()
        let quoteSource = quoteSourceTextField.text ?? ""

        let validation = viewModel.validatePrePitchInput(
            organization: organization,
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
        // Create boxscore from the storyboard text fields
        var homeTeamData: [String: AnyCodable] = [:]
        var awayTeamData: [String: AnyCodable] = [:]

        // Get scores from text fields
        homeTeamData["first_quarter"] = AnyCodable(Int(homeQ1TextField.text ?? "0") ?? 0)
        homeTeamData["second_quarter"] = AnyCodable(Int(homeQ2TextField.text ?? "0") ?? 0)
        homeTeamData["third_quarter"] = AnyCodable(Int(homeQ3TextField.text ?? "0") ?? 0)
        homeTeamData["fourth_quarter"] = AnyCodable(Int(homeQ4TextField.text ?? "0") ?? 0)
        
        // Handle overtime as array - only add value if it's greater than 0
        let homeOTScore = Int(homeOTTextField.text ?? "0") ?? 0
        homeTeamData["overtime"] = AnyCodable(homeOTScore > 0 ? [homeOTScore] : [])
        
        homeTeamData["final"] = AnyCodable(Int(homeFinalLabel.text ?? "0") ?? 0)

        awayTeamData["first_quarter"] = AnyCodable(Int(awayQ1TextField.text ?? "0") ?? 0)
        awayTeamData["second_quarter"] = AnyCodable(Int(awayQ2TextField.text ?? "0") ?? 0)
        awayTeamData["third_quarter"] = AnyCodable(Int(awayQ3TextField.text ?? "0") ?? 0)
        awayTeamData["fourth_quarter"] = AnyCodable(Int(awayQ4TextField.text ?? "0") ?? 0)
        
        // Handle overtime as array - only add value if it's greater than 0
        let awayOTScore = Int(awayOTTextField.text ?? "0") ?? 0
        awayTeamData["overtime"] = AnyCodable(awayOTScore > 0 ? [awayOTScore] : [])
        
        awayTeamData["final"] = AnyCodable(Int(awayFinalLabel.text ?? "0") ?? 0)

        return GenericBoxscore(homeTeam: homeTeamData, awayTeam: awayTeamData)
    }

    private func generateImageFilename() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        return "sports_brief_\(timestamp).jpg"
    }

    private func showImageCaptionDialog(for uploadedImage: UploadedImage, at index: Int) {
        // Set default caption and credit like Android version
        let imagePosition = viewModel.getUploadedImages().count - 1
        let defaultCaption = "Sample caption for image \(imagePosition + 1)"
        let defaultCredit = "Photo credit: \(getCurrentUserName())"

        // Update the uploaded image with default values
        viewModel.updateImageCaption(at: imagePosition, caption: defaultCaption, credit: defaultCredit)

        // No alert needed - silent success
    }

    private func getCurrentUserName() -> String {
        // Get user name from RKStorage (equivalent to SharedPreferenceManager)
        if let user = RKStorage.shared.getUserProfile(),
           let userName = user.data.attributes.name  {
            return userName
        }
        return "Unknown User"
    }
}


// MARK: - AddSportsBriefViewModelDelegate
extension AddSportsBriefViewController: AddSportsBriefViewModelDelegate {
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

    func briefSubmittedSuccessfully() {
        DispatchQueue.main.async {
            self.showAlert(title: "Success", message: "Sports brief submitted successfully!") {
                // Navigate back or dismiss the view controller
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    func selectedSchoolsLoaded(schools: [SchoolOrganizationData]) {
        DispatchQueue.main.async {
            // Handle selected schools for all user types
            if !schools.isEmpty {
                let firstSchool = schools[0]
                self.selectedOrganization = firstSchool
                self.updateSchoolOrganizationButton()
                self.updateTeamViewVisibility()
                if self.isAdmin {
                    print("Auto-selected school for admin/sysadmin user: \(firstSchool.attributes.name)")
                } else {
                    print("Auto-selected school for non-admin user: \(firstSchool.attributes.name)")
                }
            } else {
                // No selected schools found
                if self.isAdmin {
                    // For admin/sysadmin users, they can still select from all organizations
                    print("No selected schools found for admin/sysadmin user, can select from all organizations")
                } else {
                    self.showAlert(title: "No Schools Found", message: "No schools are assigned to your account. Please contact your administrator.")
                }
            }
        }
    }

    func selectedSchoolsLoadFailed(error: String) {
        DispatchQueue.main.async {
            self.showAlert(title: "Failed to Load Schools", message: "Unable to load your assigned schools: \(error)")
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
