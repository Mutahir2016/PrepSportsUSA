//
//  MoreViewController.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 04/01/2025.
//

import UIKit
import RxSwift
import RxCocoa

class MoreViewController: BaseViewController {
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var faceIdLabel: UILabel!
    
    //    @IBOutlet weak var profileInfoLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var updatePasswordLabel: UILabel!
    @IBOutlet weak var logOutLabel: UILabel!
    @IBOutlet weak var faceIdSwitchImage: UIImageView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var faceIDButton: UIButton!
    var router: MoreRouter!
    
    var logOutAction: Observable<Void> {
        return self.logOutButton.rx.tap.asObservable()
    }
    
    var faceIdAction: Observable<Void> {
        return self.faceIDButton.rx.tap.asObservable()
    }
    
    override func callingInsideViewDidLoad() {
        router = MoreRouter(self)
        bind()
        setupView()
        
        // Your custom logo image
        let logo = UIImage(named: "lumen_logo") // Replace with your logo image
        
        // Set up the custom navigation bar with the back button hidden
        setupCustomNavigationBar(
            withLogo: logo,
            rightBarButtonImage: nil,
            rightBarButtonAction: nil,
            showBackButton: true // Set to true to show the back button
        )
    }
    
    func setupView() {
        checkFaceId()
        faceIdLabel.font = UIFont.ibmRegular(size: 14.0)
        profileNameLabel.font = UIFont.ibmMedium(size: 18.0)
        emailLabel.font = UIFont.ibmRegular(size: 16.0)
        //        profileInfoLabel.font = UIFont.ibmRegular(size: 14.0)
        privacyLabel.font = UIFont.ibmRegular(size: 14.0)
        termsLabel.font = UIFont.ibmRegular(size: 14.0)
        updatePasswordLabel.font = UIFont.ibmRegular(size: 14.0)
        logOutLabel.font = UIFont.ibmRegular(size: 14.0)
        
        profileNameLabel.text = RKStorage.shared.getUserProfile()?.data.attributes.name ?? ""
        emailLabel.text = RKStorage.shared.getUserProfile()?.data.attributes.email ?? ""
    }
    
    override func setUp() {
        
    }
    
    func bind() {
        logOutAction
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                router?.logoutAndNavigateToSignIn(from: self)
            }).disposed(by: disposeBag)
        
        faceIdAction
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.toggleBiometric()
            }).disposed(by: disposeBag)
    }
    
    private func toggleBiometric() {
        if self.faceIdSwitchImage.image == UIImage(named: "on-button") {
            UserDefaults.standard.set(false, forKey: RKStorageAccount.biometricEnabled.rawValue)
            self.faceIdSwitchImage.image = UIImage(named: "off-button")
        } else {
            UserDefaults.standard.set(true, forKey: RKStorageAccount.biometricEnabled.rawValue)
            self.faceIdSwitchImage.image = UIImage(named: "on-button")
        }
    }
    private func checkFaceId() {
        
        if UserDefaults.standard.bool(forKey: RKStorageAccount.biometricEnabled.rawValue) {
            self.faceIdSwitchImage.image = UIImage(named: "on-button")
        } else {
            self.faceIdSwitchImage.image = UIImage(named: "off-button")
        }
    }
}
