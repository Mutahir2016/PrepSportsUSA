//
//  ForgotPasswordModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 04/01/2025.
//

import Foundation

struct ForgotPasswordModel: Codable {
    let meta: Meta?
    
    struct Meta: Codable {
        let message: String?
    }
}

struct VerifyOTPModel: Codable {
    let token: String?
    let created_at: Int?
    let ttl: Int?
    let user_id: Int?  // Change from String? to Int?
}
