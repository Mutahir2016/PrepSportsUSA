//
//  BaseViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 24/12/2024.
//

import Foundation
import RxSwift
import RxCocoa

class BaseViewModel {
    
    var disposeBag = DisposeBag()
    private weak var delegate: BaseViewController?
    
    func isValidEmail(_ email: String) -> Bool {
        // Example email regex: Basic validation for email format
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 1
        // Example password regex: At least 8 characters, including 1 uppercase, 1 lowercase, and 1 number
//        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$"
//        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    func getFromDate() -> String? {
        return UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
    }
    
    func getToDate() -> String? {
        return UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
    }
}
