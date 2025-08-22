//
//  Date+Displayable.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 12/01/2025.
//

import Foundation

extension Date {
    
    func formatted(template: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = template // Directly set the desired date format
        return dateFormatter.string(from: self)
    }
    
    func formatted(dateFormat: String, locale: Locale? = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = locale
        return dateFormatter.string(from: self)
    }
}
