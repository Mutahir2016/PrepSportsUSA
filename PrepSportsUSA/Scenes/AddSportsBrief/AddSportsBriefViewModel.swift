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
