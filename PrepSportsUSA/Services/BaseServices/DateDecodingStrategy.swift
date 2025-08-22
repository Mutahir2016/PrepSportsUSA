//
//  DateDecodingStrategy.swift
//  Rikstoto
//
//  Created by Apphuset on 2022-11-26.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static let appCustomStrategy: Self = {
        return .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()

            if let timeIntervalSince1970 = try? container.decode(Double.self) {
                return Date(timeIntervalSince1970: timeIntervalSince1970)
            } else if let timeString = try? container.decode(String.self) {
                if let timeIntervalSince1970 = Double(timeString) {
                    return Date(timeIntervalSince1970: timeIntervalSince1970)
                } else {
                    let formatter = ISO8601DateFormatter()
                    if let date = formatter.date(from: timeString) {
                        return date
                    } else {
                        let formatter = DateFormatter.yyyyMMddHHmmss
                        if let date = formatter.date(from: timeString) {
                            return date
                        } else {
                            let isoFormatter = ISO8601DateFormatter()
                            isoFormatter.formatOptions = isoFormatter.formatOptions.union(.withFractionalSeconds)
                            if let date = isoFormatter.date(from: timeString) {
                                return date
                            } else {
                                let context = DecodingError.Context(codingPath:
                                                container.codingPath, debugDescription: "Expected date string or Unix value")
                                throw DecodingError.dataCorrupted(context)
                            }
                        }
                    }
                }
            } else {
                let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Expected date string or Unix value")
                throw DecodingError.dataCorrupted(context)
            }
        }
    }()
}

extension DateFormatter {

    static let yyyyMMddHHmmss: DateFormatter = {
        let formatter = DateFormatter()
        // 2021-09-19T22:20:00
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        // We need date and time in en_US format all time
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
