//
//  TokenHandler.swift
//  Rikstoto
//
//  Created by Apphuset on 2022-11-29.
//

import Foundation
import Alamofire

final class RKAuthCredential: AuthenticationCredential {

    private var authStorage: AuthStorage
    init(authStorage: AuthStorage) {
        self.authStorage = authStorage
    }

    var requiresRefresh: Bool {
        
        guard let accessToken = authStorage.accessToken, !accessToken.isEmpty else {
            return false
        }

        if let exp = authStorage.expirationDate {
            return exp.timeIntervalSinceNow < 300 // 5 mins refreshing in advance
        } else {
            return false
        }
    }

    var accessToken: String {
        authStorage.accessToken ?? ""
    }
}
