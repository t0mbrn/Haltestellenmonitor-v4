//
//  DateManager.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 20.04.25.
//

import Foundation

// DateFormatter is expensive to create and these run for every list row; formatting is thread-safe.
private func formatter(_ format: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter
}

private let timeFormatter = formatter("HH:mm")
private let urlTimeFormatter = formatter("HHmm")
private let urlDateFormatter = formatter("yyyyMMdd")

public func getTimeStamp(date: Date) -> String {
    timeFormatter.string(from: date)
}

public func getTimeStampURL(date: Date = Date()) -> String {
    urlTimeFormatter.string(from: date)
}

public func getDateStampURL(date: Date = Date()) -> String {
    urlDateFormatter.string(from: date)
}

/// Whole-minute difference with seconds ignored, as departure boards show delays.
public func minutesBetween(_ from: Date, _ to: Date) -> Int {
    let calendar = Calendar.current
    let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
    return calendar.dateComponents([.minute], from: calendar.dateComponents(components, from: from), to: calendar.dateComponents(components, from: to)).minute!
}

extension JSONDecoder {
    /// EFA (efa.vvo-online.de) sends ISO 8601 timestamps.
    public static var efa: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
