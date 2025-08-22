//
//  StringExtension.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 04/02/2025.
//
import Foundation

extension String {
    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        return formatter.date(from: self)
    }
}
