//
//  Route.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

public struct Route: Hashable, Codable {
    public var ShortDistance: Bool?
    public var Interchanges: Int
    public var PartialRoutes: [PartialRoute]

    public func getStartTime() -> Date? {
        guard let regularStop = PartialRoutes.first?.RegularStops?.first else { return nil }
        return regularStop.DepartureRealTime ?? regularStop.DepartureTime
    }

    public func getStartTimeString() -> String {
        getStartTime().map { getTimeStamp(date: $0) } ?? "00:00"
    }

    public func getEndTime() -> Date? {
        guard let regularStop = PartialRoutes.last?.RegularStops?.last else { return nil }
        return regularStop.ArrivalRealTime ?? regularStop.ArrivalTime
    }

    public func getEndTimeString() -> String {
        getEndTime().map { getTimeStamp(date: $0) } ?? "00:00"
    }

    public func getTimeDifference() -> Int {
        guard let startTime = getStartTime(), let endTime = getEndTime() else { return 0 }
        return minutesBetween(startTime, endTime)
    }
}
