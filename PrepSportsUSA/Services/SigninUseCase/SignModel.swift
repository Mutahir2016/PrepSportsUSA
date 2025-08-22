//
//  SignModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 28/12/2024.
//

import Foundation

typealias signInData = SignModel.LoginResponse

struct SignModel: Codable {
    struct LoginResponse: Codable {
        var meta: MetaData?
        var token: String?
        var user_id: Int?
        var error: String?
    }
    
    struct MetaData: Codable {
        var two_factor_required: Bool?
        var code_send: Bool?
        var authy_id : String?
        var user_id: Int?
    }
}
