//
//  CustomError.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 28/12/2024.
//

import Foundation

enum CustomError: Error, Equatable {
    case connectionError
    case jsonSerializeError
    case urlNotFound
    case serverError
    case notFoundError
    case emptyResponse
    case userAlreadyExists
    case sessionExpired
}
