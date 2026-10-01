//
//  DateParser.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation
import RegexBuilder

public struct DateParser {
    public static func extractTimestamp(time: String) -> Date? {
        let timeRef = Reference(Int64.self)
        let timeZoneRef = Reference(Int.self)
        let pattern = Regex {
            "/Date("

            TryCapture(as: timeRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int64(match)
            }

            ChoiceOf {
                "-"
                "+"
            }

            TryCapture(as: timeZoneRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            ")/"
        }

        if let result = try? pattern.wholeMatch(in: time) {
            var timestamp = result[timeRef]
            timestamp = timestamp / 1000
            return Date(timeIntervalSince1970: TimeInterval(timestamp))
        }

        return nil
    }
}

extension JSONDecoder {
    /// WebAPI (webapi.vvo-online.de) sends .NET style "/Date(1681824120000-0000)/" timestamps.
    public static var vvo: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = DateParser.extractTimestamp(time: string) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
            }
            return date
        }
        return decoder
    }
}
