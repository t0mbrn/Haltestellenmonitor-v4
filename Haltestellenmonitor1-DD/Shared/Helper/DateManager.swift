//
//  DateManager.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 20.04.25.
//

import Foundation

func getTimeStamp(date: Date) -> String {
    let dFormatter = DateFormatter()
    dFormatter.dateFormat = "HH:mm"
    return dFormatter.string(for: date) ?? "n/a"
}

func getTimeStampURL(date: Date = Date()) -> String {
    let dFormatter = DateFormatter()
    dFormatter.dateFormat = "HHmm"
    return dFormatter.string(for: date) ?? ""
}

func getDateStampURL(date: Date = Date()) -> String {
    let dFormatter = DateFormatter()
    dFormatter.dateFormat = "yyyyMMdd"
    return dFormatter.string(for: date) ?? ""
}


/// Whole-minute difference with seconds ignored, as departure boards show delays.
func minutesBetween(_ from: Date, _ to: Date) -> Int {
    let calendar = Calendar.current
    let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
    return calendar.dateComponents([.minute], from: calendar.dateComponents(components, from: from), to: calendar.dateComponents(components, from: to)).minute!
}

extension JSONDecoder {
    /// EFA (efa.vvo-online.de) sends ISO 8601 timestamps.
    static var efa: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
