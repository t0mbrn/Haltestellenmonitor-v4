//
//  Route.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

struct Route: Hashable, Codable {
    var ShortDistance: Bool?
    var Interchanges: Int
    var PartialRoutes: [PartialRoute]

    func getStartTime() -> Date? {
        guard let regularStop = PartialRoutes.first?.RegularStops?.first else { return nil }
        return regularStop.DepartureRealTime ?? regularStop.DepartureTime
    }

    func getStartTimeString() -> String {
        getStartTime().map { getTimeStamp(date: $0) } ?? "00:00"
    }

    func getEndTime() -> Date? {
        guard let regularStop = PartialRoutes.last?.RegularStops?.last else { return nil }
        return regularStop.ArrivalRealTime ?? regularStop.ArrivalTime
    }

    func getEndTimeString() -> String {
        getEndTime().map { getTimeStamp(date: $0) } ?? "00:00"
    }

    func getTimeDifference() -> Int {
        guard let startTime = getStartTime(), let endTime = getEndTime() else { return 0 }
        return minutesBetween(startTime, endTime)
    }
}
