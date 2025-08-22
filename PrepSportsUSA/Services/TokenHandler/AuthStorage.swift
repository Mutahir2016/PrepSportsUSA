//
//  RKStorage+Auth.swift
//  Rikstoto
//
//  Created by Apphuset on 2022-11-29.
//

import Foundation

protocol AuthStorage {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    var expirationDate: Date? { get set }
}

extension RKStorage: AuthStorage {
    var accessToken: String? {
        get {
            getUserToken(service: RKStorageService.accessTokenService.rawValue,
                         account: RKStorageAccount.accessTokenAccount.rawValue)
        }
        set {
            try? saveValueInKeyChain(service: RKStorageService.accessTokenService.rawValue,
                                account: RKStorageAccount.accessTokenAccount.rawValue,
                                password: newValue?.data(using: .utf8) ?? Data())
        }
    }
    
    var refreshToken: String? {
        get {
            getUserToken(service: RKStorageService.refreshTokenService.rawValue,
                         account: RKStorageAccount.refreshTokenAccount.rawValue)
        }
        set {
            try? saveValueInKeyChain(service: RKStorageService.refreshTokenService.rawValue,
                                     account: RKStorageAccount.refreshTokenAccount.rawValue,
                                     password: newValue?.data(using: .utf8) ?? Data())
        }
    }
    
    var expirationDate: Date? {
        get {
            guard let data = loadKeyChainValue(service: RKStorageService.accessTokenExpiration.rawValue,
                                               account: RKStorageAccount.accessTokenExpiration.rawValue) else {
                return nil
            }
            let date = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Date
            
//            print("GET DATE: \(date)")
            return date
        }
        set {
            if let date = newValue, let data = try? NSKeyedArchiver.archivedData(withRootObject: date, requiringSecureCoding: false) {
                try? saveValueInKeyChain(service: RKStorageService.accessTokenExpiration.rawValue,
                                         account: RKStorageAccount.accessTokenExpiration.rawValue,
                                         password: data)
                
//                print("SAVE DATE: \(date)")
            }
        }
    }
}
