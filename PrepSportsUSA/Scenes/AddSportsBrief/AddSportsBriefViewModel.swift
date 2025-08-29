//
//  AddSportsBriefViewModel.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import RxSwift
import RxRelay
import UIKit

protocol AddSportsBriefViewModelDelegate: AnyObject {
    func briefSubmittedSuccessfully()
    func briefSubmissionFailed(error: String)
    func imageUploadProgress(progress: Float)
    func imageUploadCompleted(uploadedImage: UploadedImage)
    func imageUploadFailed(error: String)
    func selectedSchoolsLoaded(schools: [SchoolOrganizationData])
    func selectedSchoolsLoadFailed(error: String)
}

enum TeamSide {
    case home
    case away
}

class AddSportsBriefViewModel: BaseViewModel {

    // MARK: - Properties
    var addSportsBriefUseCase: AddSportsBriefUseCase?
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    let sessionExpiredRelay = PublishRelay<Void>()
    let submissionSuccessRelay = PublishRelay<Void>()
    let submissionErrorRelay = PublishRelay<String>()
    let imageUploadProgressRelay = BehaviorRelay<Float>(value: 0.0)
    let imageUploadSuccessRelay = PublishRelay<UploadedImage>()
    let imageUploadErrorRelay = PublishRelay<String>()

    weak var delegate: AddSportsBriefViewModelDelegate?

    // Uploaded images array
    private var uploadedImages: [UploadedImage] = []

    init(useCase: AddSportsBriefUseCase = AddSportsBriefUseCase()) {
        super.init()
        self.addSportsBriefUseCase = useCase
    }

    func submitBrief(title: String, description: String) {
        isLoadingRelay.accept(true)

        addSportsBriefUseCase?
            .submitSportsBrief(title: title, description: description)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                guard let self = self else { return }
                self.isLoadingRelay.accept(false)

                if success {
                    print("Brief submitted successfully")
                    self.submissionSuccessRelay.accept(())
                    self.delegate?.briefSubmittedSuccessfully()
                } else {
                    let errorMessage = "Failed to submit brief"
                    print("Brief submission failed: \(errorMessage)")
                    self.submissionErrorRelay.accept(errorMessage)
                    self.delegate?.briefSubmissionFailed(error: errorMessage)
                }
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.isLoadingRelay.accept(false)

                if let customError = error as? CustomError, customError == .sessionExpired {
                    self.sessionExpiredRelay.accept(())
                } else {
                    let errorMessage = error.localizedDescription
                    print("API Error: \(errorMessage)")
                    self.submissionErrorRelay.accept(errorMessage)
                    self.delegate?.briefSubmissionFailed(error: errorMessage)
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Image Upload
    func uploadImage(_ image: UIImage, filename: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            let error = "Failed to convert image to data"
            imageUploadErrorRelay.accept(error)
            delegate?.imageUploadFailed(error: error)
            return
        }

        let contentType = "image/jpeg"
        let mediaRequest = PrePitchMediaRequest(filename: filename, contentType: contentType)

        // Step 1: Get presigned URL
        addSportsBriefUseCase?
            .createPrePitchMediaLink(request: mediaRequest)
            .flatMap { [weak self] response -> Observable<(PrePitchMediaResponse, Bool)> in
                guard let self = self else { return Observable.empty() }

                // Step 2: Upload image to presigned URL
                return self.addSportsBriefUseCase!
                    .uploadImageToPresignedUrl(
                        imageData: imageData,
                        presignedUrl: response.presignedUrl,
                        contentType: contentType
                    )
                    .map { success in (response, success) }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (response, success) in
                guard let self = self else { return }

                if success {
                    let uploadedImage = UploadedImage(
                        image: image,
                        name: filename,
                        publicUrl: response.publicUrl,
                        contentType: contentType,
                        size: Int64(imageData.count)
                    )

                    self.uploadedImages.append(uploadedImage)
                    self.imageUploadSuccessRelay.accept(uploadedImage)
                    self.delegate?.imageUploadCompleted(uploadedImage: uploadedImage)
                } else {
                    let error = "Failed to upload image to server"
                    self.imageUploadErrorRelay.accept(error)
                    self.delegate?.imageUploadFailed(error: error)
                }
            }, onError: { [weak self] error in
                guard let self = self else { return }
                let errorMessage = error.localizedDescription
                self.imageUploadErrorRelay.accept(errorMessage)
                self.delegate?.imageUploadFailed(error: errorMessage)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Submit Pre Pitch
    func submitPrePitch(
        organizationId: String,
        teamId: String,
        gameId: String,
        description: String,
        quotes: [String],
        quoteSource: String,
        boxscore: GenericBoxscore
    ) {
        isLoadingRelay.accept(true)

        // Create media requests from uploaded images
        let mediaRequests = uploadedImages.map { image in
            MediaRequest(
                url: image.publicUrl ?? "",
                filename: image.name,
                caption: image.caption ?? "",
                credits: image.credit ?? ""
            )
        }

        // Default pre pitch type ID (Sports Brief)
        let prePitchTypeId = "aa8f29ad-0405-43c0-9d03-1ecb43f3eb54"

        let request = PrePitchCreateRequest(
            prePitchTypeId: prePitchTypeId,
            limparTeamId: teamId,
            limparGameId: gameId,
            description: description,
            media: mediaRequests,
            quotes: quotes,
            quoteSource: quoteSource,
            boxscore: boxscore
        )

        // Print JSON for debugging
        if let jsonData = try? JSONEncoder().encode(request),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("PrePitchCreateRequest JSON:")
            print(jsonString)
        } else {
            print("Failed to encode PrePitchCreateRequest to JSON")
        }

        addSportsBriefUseCase?
            .createPrePitch(request: request)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                self.isLoadingRelay.accept(false)

                print("Pre pitch submitted successfully")
                self.submissionSuccessRelay.accept(())
                self.delegate?.briefSubmittedSuccessfully()
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.isLoadingRelay.accept(false)

                if let customError = error as? CustomError, customError == .sessionExpired {
                    self.sessionExpiredRelay.accept(())
                } else {
                    let errorMessage = error.localizedDescription
                    print("Pre pitch submission failed: \(errorMessage)")
                    self.submissionErrorRelay.accept(errorMessage)
                    self.delegate?.briefSubmissionFailed(error: errorMessage)
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Validation
    func validateInput(title: String?, description: String?) -> Bool {
        guard let title = title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let description = description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              description != "Enter brief description..." else {
            return false
        }
        return true
    }

    func validatePrePitchInput(
        organization: SchoolOrganizationData?,
        team: TeamData?,
        game: GameData?,
        description: String?,
        quotes: [String],
        quoteSource: String?
    ) -> (isValid: Bool, errorMessage: String?) {

        guard organization != nil else {
            return (false, "Please select School Organization")
        }

        guard team != nil else {
            return (false, "Please select Team")
        }

        guard game != nil else {
            return (false, "Please select Game")
        }

        guard let desc = description, !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return (false, "Please enter description")
        }

        // Check if any quote is filled, then quote source is required
        if !quotes.isEmpty && (quoteSource?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
            return (false, "Quote Source is required when quotes are provided")
        }

        return (true, nil)
    }

    // MARK: - Helper Methods
    func getUploadedImages() -> [UploadedImage] {
        return uploadedImages
    }

    func removeUploadedImage(at index: Int) {
        guard index < uploadedImages.count else { return }
        uploadedImages.remove(at: index)
    }

    func updateImageCaption(at index: Int, caption: String, credit: String) {
        guard index < uploadedImages.count else { return }
        uploadedImages[index].caption = caption
        uploadedImages[index].credit = credit
    }

    func clearUploadedImages() {
        uploadedImages.removeAll()
    }

    // MARK: - Boxscore Creation Methods
    func createSportSpecificBoxscore(
        sport: String,
        homeScores: [Int]? = nil,
        awayScores: [Int]? = nil,
        footballBoxscore: GenericBoxscore? = nil
    ) -> GenericBoxscore {

        switch sport.lowercased() {
        case "golf":
            if let homeScores = homeScores, let awayScores = awayScores {
                return createGolfBoxscore(homeScores: homeScores, awayScores: awayScores)
            }
            return GenericBoxscore(homeTeam: [:], awayTeam: [:])

        case "tennis":
            if let homeScores = homeScores, let awayScores = awayScores {
                return createTennisBoxscore(homeScores: homeScores, awayScores: awayScores)
            }
            return GenericBoxscore(homeTeam: [:], awayTeam: [:])

        case "volleyball":
            if let homeScores = homeScores, let awayScores = awayScores {
                return createVolleyballBoxscore(homeScores: homeScores, awayScores: awayScores)
            }
            return GenericBoxscore(homeTeam: [:], awayTeam: [:])

        default:
            // Football and other sports use the provided football boxscore
            return footballBoxscore ?? GenericBoxscore(homeTeam: [:], awayTeam: [:])
        }
    }

    private func createGolfBoxscore(homeScores: [Int], awayScores: [Int]) -> GenericBoxscore {
        let golfBoxscore = GolfBoxscore(
            homeTeam: GolfTeamScores(scores: homeScores),
            awayTeam: GolfTeamScores(scores: awayScores)
        )

        return convertGolfBoxscoreToGeneric(golfBoxscore)
    }

    private func createTennisBoxscore(homeScores: [Int], awayScores: [Int]) -> GenericBoxscore {
        let tennisBoxscore = TennisBoxscore(
            homeTeam: TennisTeamScores(scores: homeScores),
            awayTeam: TennisTeamScores(scores: awayScores)
        )

        return convertSetBasedBoxscoreToGeneric(tennisBoxscore)
    }

    private func createVolleyballBoxscore(homeScores: [Int], awayScores: [Int]) -> GenericBoxscore {
        let volleyballBoxscore = VolleyballBoxscore(
            homeTeam: VolleyballTeamScores(scores: homeScores),
            awayTeam: VolleyballTeamScores(scores: awayScores)
        )

        return convertSetBasedBoxscoreToGeneric(volleyballBoxscore)
    }

    private func convertGolfBoxscoreToGeneric(_ golfBoxscore: GolfBoxscore) -> GenericBoxscore {
        var homeTeamData: [String: AnyCodable] = [:]
        var awayTeamData: [String: AnyCodable] = [:]

        // Convert golf scores to generic format
        homeTeamData["one"] = AnyCodable(golfBoxscore.homeTeam.one)
        homeTeamData["two"] = AnyCodable(golfBoxscore.homeTeam.two)
        homeTeamData["three"] = AnyCodable(golfBoxscore.homeTeam.three)
        homeTeamData["four"] = AnyCodable(golfBoxscore.homeTeam.four)
        homeTeamData["five"] = AnyCodable(golfBoxscore.homeTeam.five)
        homeTeamData["six"] = AnyCodable(golfBoxscore.homeTeam.six)
        homeTeamData["seven"] = AnyCodable(golfBoxscore.homeTeam.seven)
        homeTeamData["eight"] = AnyCodable(golfBoxscore.homeTeam.eight)
        homeTeamData["nine"] = AnyCodable(golfBoxscore.homeTeam.nine)
        homeTeamData["ten"] = AnyCodable(golfBoxscore.homeTeam.ten)
        homeTeamData["eleven"] = AnyCodable(golfBoxscore.homeTeam.eleven)
        homeTeamData["twelve"] = AnyCodable(golfBoxscore.homeTeam.twelve)
        homeTeamData["thirteen"] = AnyCodable(golfBoxscore.homeTeam.thirteen)
        homeTeamData["fourteen"] = AnyCodable(golfBoxscore.homeTeam.fourteen)
        homeTeamData["fifteen"] = AnyCodable(golfBoxscore.homeTeam.fifteen)
        homeTeamData["sixteen"] = AnyCodable(golfBoxscore.homeTeam.sixteen)
        homeTeamData["seventeen"] = AnyCodable(golfBoxscore.homeTeam.seventeen)
        homeTeamData["eighteen"] = AnyCodable(golfBoxscore.homeTeam.eighteen)
        homeTeamData["OUT"] = AnyCodable(golfBoxscore.homeTeam.out)
        homeTeamData["IN"] = AnyCodable(golfBoxscore.homeTeam.in)
        homeTeamData["TOT"] = AnyCodable(golfBoxscore.homeTeam.tot)

        awayTeamData["one"] = AnyCodable(golfBoxscore.awayTeam.one)
        awayTeamData["two"] = AnyCodable(golfBoxscore.awayTeam.two)
        awayTeamData["three"] = AnyCodable(golfBoxscore.awayTeam.three)
        awayTeamData["four"] = AnyCodable(golfBoxscore.awayTeam.four)
        awayTeamData["five"] = AnyCodable(golfBoxscore.awayTeam.five)
        awayTeamData["six"] = AnyCodable(golfBoxscore.awayTeam.six)
        awayTeamData["seven"] = AnyCodable(golfBoxscore.awayTeam.seven)
        awayTeamData["eight"] = AnyCodable(golfBoxscore.awayTeam.eight)
        awayTeamData["nine"] = AnyCodable(golfBoxscore.awayTeam.nine)
        awayTeamData["ten"] = AnyCodable(golfBoxscore.awayTeam.ten)
        awayTeamData["eleven"] = AnyCodable(golfBoxscore.awayTeam.eleven)
        awayTeamData["twelve"] = AnyCodable(golfBoxscore.awayTeam.twelve)
        awayTeamData["thirteen"] = AnyCodable(golfBoxscore.awayTeam.thirteen)
        awayTeamData["fourteen"] = AnyCodable(golfBoxscore.awayTeam.fourteen)
        awayTeamData["fifteen"] = AnyCodable(golfBoxscore.awayTeam.fifteen)
        awayTeamData["sixteen"] = AnyCodable(golfBoxscore.awayTeam.sixteen)
        awayTeamData["seventeen"] = AnyCodable(golfBoxscore.awayTeam.seventeen)
        awayTeamData["eighteen"] = AnyCodable(golfBoxscore.awayTeam.eighteen)
        awayTeamData["OUT"] = AnyCodable(golfBoxscore.awayTeam.out)
        awayTeamData["IN"] = AnyCodable(golfBoxscore.awayTeam.in)
        awayTeamData["TOT"] = AnyCodable(golfBoxscore.awayTeam.tot)

        return GenericBoxscore(homeTeam: homeTeamData, awayTeam: awayTeamData)
    }

    private func convertSetBasedBoxscoreToGeneric(_ setBasedBoxscore: SetBasedBoxscore) -> GenericBoxscore {
        var homeTeamData: [String: AnyCodable] = [:]
        var awayTeamData: [String: AnyCodable] = [:]

        // Convert set-based scores to generic format (works for tennis, volleyball, etc.)
        homeTeamData["first_set"] = AnyCodable(setBasedBoxscore.homeTeam.firstSet)
        homeTeamData["second_set"] = AnyCodable(setBasedBoxscore.homeTeam.secondSet)
        homeTeamData["third_set"] = AnyCodable(setBasedBoxscore.homeTeam.thirdSet)
        homeTeamData["fourth_set"] = AnyCodable(setBasedBoxscore.homeTeam.fourthSet)
        homeTeamData["fifth_set"] = AnyCodable(setBasedBoxscore.homeTeam.fifthSet)
        homeTeamData["final_score"] = AnyCodable(setBasedBoxscore.homeTeam.finalScore)

        awayTeamData["first_set"] = AnyCodable(setBasedBoxscore.awayTeam.firstSet)
        awayTeamData["second_set"] = AnyCodable(setBasedBoxscore.awayTeam.secondSet)
        awayTeamData["third_set"] = AnyCodable(setBasedBoxscore.awayTeam.thirdSet)
        awayTeamData["fourth_set"] = AnyCodable(setBasedBoxscore.awayTeam.fourthSet)
        awayTeamData["fifth_set"] = AnyCodable(setBasedBoxscore.awayTeam.fifthSet)
        awayTeamData["final_score"] = AnyCodable(setBasedBoxscore.awayTeam.finalScore)

        return GenericBoxscore(homeTeam: homeTeamData, awayTeam: awayTeamData)
    }

    // MARK: - Fetch Selected Schools for Non-Admin Users
    func fetchSelectedSchools() {
        isLoadingRelay.accept(true)

        addSportsBriefUseCase?
            .getSelectedSchools(page: 1, pageSize: 1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                self.isLoadingRelay.accept(false)

                print("Selected schools loaded successfully: \(response.data.count) schools")
                self.delegate?.selectedSchoolsLoaded(schools: response.data)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.isLoadingRelay.accept(false)

                let errorMessage = error.localizedDescription
                print("Failed to load selected schools: \(errorMessage)")
                self.delegate?.selectedSchoolsLoadFailed(error: errorMessage)
            })
            .disposed(by: disposeBag)
    }
}
