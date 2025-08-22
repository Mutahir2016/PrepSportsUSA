//
//  TokenAPIService.swift
//  Rikstoto
//
//  Created by Apphuset on 2022-11-29.
//

import Foundation
import RxSwift
import Alamofire

enum RefreshTokenError: Error {
    case service(error: Error)
}


