//
//  RKStorage.swift
//  Rikstoto
//
//  Created by 7Peaks on 29/9/2565 BE.
//

import Foundation
import Security

enum LoginFlowStartingPoint: Codable {
    
    enum Responsibility: Codable {
        case limit, behavior, gamePause, gameStop
    }
    
    case homeGameOverlay, result, profile, responsibility(Responsibility)
}

protocol RKStorageProtocol {
    func getUserToken(service: String, account: String) -> String?
    var valuePropShown: Bool { get set }
    var isValuePropFlow: Bool { get set }
    
    var loginFlowStartingPoint: LoginFlowStartingPoint? { get set }
    var hasResponsbilityUnreadMessage: Bool { get set }
    var hasSuccessfulGamePause: Bool { get set }
    
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
}

enum KeyChainError: Error {
    case duplicateEntry
    case unknown(OSStatus)
}

enum SignInKey: String {
    case signIn = "SignInModel"
    case userProfile = "UserProfile"
}

enum StoriesHomeKey: String {
    case fromDateRange = "FromDateRange"
    case toDateRange = "ToDateRange"
    case network = "Network"
    case project = "Project"
}

enum RKStorageKey: String {
    case userRKToken = "UserRKToken"
    case userRKInfo = "UserRKInfo"
    case userRefreshToken = "UserRKRefreshToken"
}

enum UserCredentialKeys: String {
    case email = "Email"
    case password = "Password"
}

enum RKStorageAccount: String {
    case biometricEnabled = "BiometricEnabled"
    case accessTokenAccount = "AccessTokenAccount"
    case refreshTokenAccount = "RefreshTokenAccount"
    case accessTokenExpiration = "AccessTokenExpirationAccount"
    case biometricPinAccount = "BiometricPinAccount"
    case biometricEnabledUser = "BiometricEnabledUser"

}

enum RKStorageService: String {
    case accessTokenService = "AccessTokenService"
    case refreshTokenService = "RefreshTokenService"
    case accessTokenExpiration = "AccessTokenExpirationService"
    case biometricPinService = "BiometricPinService"
}

enum RKStorageKeyType: String {
    case rikstotoInstalled = "RikstotoInstalled"
    case rikstotoLogin = "RikstotoLogin"
    
}

enum RKBiometricKey: String {
    case biometricAllowedKey = "BiometricAllowedKey"
    case biometricIsConfigured = "BiometricIsConfigured"
}

class RKStorage: RKStorageProtocol {
    
    static let shared = RKStorage()
    private let userdefault = UserDefaults.standard
    
    func getUserToken(service: String, account: String) -> String? {
        guard let data = loadKeyChainValue(service: service, account: account) else {
            print("failed to read data")
            return nil
        }
        return String(decoding: data, as: UTF8.self)
    }
    
    func tokenExists() -> Bool {
        guard let token = loadKeyChainValue(service:
                                        RKStorageService.accessTokenService.rawValue,
                                     account: RKStorageAccount.accessTokenAccount.rawValue) else {
            return false
        }
        print("token value: \(token)")
        return true
    }
    
    func saveSignIn(tokenModel: signInData) {
        do {
            let encodedData = try JSONEncoder().encode(tokenModel)
            userdefault.set(encodedData, forKey: SignInKey.signIn.rawValue)
        } catch {
            print("Failed to encode signInData: \(error)")
        }
    }
    
    func getSignIn() -> signInData? {
        if let savedData = userdefault.data(forKey: SignInKey.signIn.rawValue) {
            do {
                return try JSONDecoder().decode(signInData.self, from: savedData)
            } catch {
                print("Failed to decode signInData: \(error)")
            }
        }
        return nil
    }
    
    func saveUserProfile(userProfile: UserProfile) {
        do {
            let encodedData = try JSONEncoder().encode(userProfile)
            userdefault.set(encodedData, forKey: SignInKey.userProfile.rawValue)
        } catch {
            print("Failed to encode UserProfile: \(error)")
        }
    }
    
    func getUserProfile() -> UserProfile? {
        if let savedData = userdefault.data(forKey: SignInKey.userProfile.rawValue) {
            do {
                return try JSONDecoder().decode(UserProfile.self, from: savedData)
            } catch {
                print("Failed to decode UserProfile: \(error)")
            }
        }
        return nil
    }
    
    func saveValueInKeyChain(service: String, account: String, password: Data, override: Bool = true) throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password as AnyObject
        ]
        
        var status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            if override {
                status = SecItemUpdate(query as CFDictionary, [kSecValueData: password] as CFDictionary)
            } else {
                throw KeyChainError.duplicateEntry
            }
        }
        
        guard status == errSecSuccess else {
            throw KeyChainError.unknown(status)
        }
    }
    
    func loadKeyChainValue(service: String, account: String) -> Data? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        print("Read status:\(status)")
        return result as? Data
    }
    
    func clearLoggedInPreferences() {
        UserDefaults.standard.set(false, forKey: RKBiometricKey.biometricAllowedKey.rawValue)
        userdefault.set(nil, forKey: RKStorageKey.userRKInfo.rawValue)
        
        try? clearKeyChainAndUserDefaults(
            service: RKStorageService.accessTokenService.rawValue,
            account: RKStorageAccount.accessTokenAccount.rawValue)
        try? clearKeyChainAndUserDefaults(
            service: RKStorageService.refreshTokenService.rawValue,
            account: RKStorageAccount.refreshTokenAccount.rawValue)
        try? clearKeyChainAndUserDefaults(
            service: RKStorageService.accessTokenExpiration.rawValue,
            account: RKStorageAccount.accessTokenExpiration.rawValue)
        try? clearKeyChainAndUserDefaults(
            service: RKStorageService.biometricPinService.rawValue,
            account: RKStorageAccount.biometricPinAccount.rawValue)
        
        loginFlowStartingPoint = nil
        hasResponsbilityUnreadMessage = false
    }
    
    private func clearKeyChainAndUserDefaults(service: String, account: String) throws {
        let deleteQuery = [kSecClass as String:
                           kSecClassGenericPassword as String,
                           kSecAttrAccount as String: account,
                           kSecAttrService as String: service]
        let status = SecItemDelete(deleteQuery as CFDictionary)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status),
                          userInfo: [NSLocalizedDescriptionKey:
                                        SecCopyErrorMessageString(status, nil) ?? "Undefined error"])
        }
    }
    
    func saveNetworkData<T: Codable>(_ object: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(object) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func getNetwokData<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let object = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return object
    }
}

private let valuePropShownKey = "ValuePropShown"
private let valuePropFlow = "ValuePropFlow"
private let loginFlowStartingPointKey = "LoginFlowStartingPoint"
private let hasResponsbilityUnreadMessageKey = "HasResponsbilityUnreadMessageKey"
private let hasSuccessfulGamePauseKey = "HasSuccessfulGamePauseKey"
private let hasSuccessfulGameStopKey = "HasSuccessfulGameStopKey"
private let hasOnBoardingCompletedKey = "HasOnBoardingCompletedKey"
private let hasReConfirmedLimitKey = "HasReConfirmedLimitKey"
private let isActiveUserKey = "IsActiveUserKey"
private let isAgreementUpdatedKey = "IsAgreementUpdatedKey"
private let shouldUpdateBetLimitKey = "ShouldUpdateBetLimitKey"

extension RKStorage {
    var valuePropShown: Bool {
        get { userdefault.bool(forKey: valuePropShownKey) }
        set { userdefault.set(newValue, forKey: valuePropShownKey) }
    }
    
    var isValuePropFlow: Bool {
        get { userdefault.bool(forKey: valuePropFlow) }
        set { userdefault.set(newValue, forKey: valuePropFlow) }
    }
    
    var loginFlowStartingPoint: LoginFlowStartingPoint? {
        get {
            if let data = userdefault.data(forKey: loginFlowStartingPointKey) {
                return try? JSONDecoder().decode(LoginFlowStartingPoint.self, from: data)
            } else {
                return nil
            }
        }
        set {
            if let value = newValue {
                let data = try? JSONEncoder().encode(value)
                userdefault.set(data, forKey: loginFlowStartingPointKey)
            } else {
                userdefault.set(nil, forKey: loginFlowStartingPointKey)
            }
        }
    }
    
    var hasResponsbilityUnreadMessage: Bool {
        get { userdefault.bool(forKey: hasResponsbilityUnreadMessageKey) }
        set { userdefault.set(newValue, forKey: hasResponsbilityUnreadMessageKey) }
    }
    
    var hasSuccessfulGamePause: Bool {
        get { userdefault.bool(forKey: hasSuccessfulGamePauseKey) }
        set { userdefault.set(newValue, forKey: hasSuccessfulGamePauseKey) }
    }
    
    var hasSuccessfulGameStop: Bool {
        get { userdefault.bool(forKey: hasSuccessfulGameStopKey) }
        set { userdefault.set(newValue, forKey: hasSuccessfulGameStopKey) }
    }
    
    var hasOnBoardingCompleted: Bool {
        get { userdefault.bool(forKey: hasOnBoardingCompletedKey) }
        set { userdefault.set(newValue, forKey: hasOnBoardingCompletedKey) }
    }
    
    var hasReConfirmedLimit: Bool {
        get { userdefault.bool(forKey: hasReConfirmedLimitKey) }
        set { userdefault.set(newValue, forKey: hasReConfirmedLimitKey) }
    }
    
    var isActiveUser: Bool {
        get { userdefault.bool(forKey: isActiveUserKey) }
        set { userdefault.set(newValue, forKey: isActiveUserKey) }
    }
    
    var isAgreementUpdated: Bool {
        get { userdefault.bool(forKey: isAgreementUpdatedKey) }
        set { userdefault.set(newValue, forKey: isAgreementUpdatedKey) }
    }
    
    var shouldUpdateBetLimit: Bool {
        get { userdefault.bool(forKey: shouldUpdateBetLimitKey) }
        set { userdefault.set(newValue, forKey: shouldUpdateBetLimitKey) }
    }
}
