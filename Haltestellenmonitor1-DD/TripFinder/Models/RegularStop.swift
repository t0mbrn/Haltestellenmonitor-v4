//
//  RegularStop.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

struct RegularStop: Hashable, Codable {
    var ArrivalTime: Date
    var DepartureTime: Date
    var ArrivalRealTime: Date?
    var DepartureRealTime: Date?
    var Place: String
    var Name: String
    var type: String
    var Platform: DeparturePlatform?
    var Latitude: Int
    var Longitude: Int
    var DepartureState: String?
    var ArrivalState: String?
    var DataId: String

    private enum CodingKeys: String, CodingKey {
        case ArrivalTime, DepartureTime, ArrivalRealTime, DepartureRealTime, Place, Name, type = "Type", Platform, Latitude, Longitude, DepartureState, ArrivalState, DataId
    }

    func getArrivalTime() -> String {
        getTimeStamp(date: ArrivalTime)
    }

    func getDepartureTime() -> String {
        getTimeStamp(date: DepartureTime)
    }

    func getRealArrivalTime() -> String {
        getTimeStamp(date: ArrivalRealTime ?? ArrivalTime)
    }

    func getRealDepartureTime() -> String {
        getTimeStamp(date: DepartureRealTime ?? DepartureTime)
    }

    func getTimeDifference() -> Int {
        guard let ArrivalRealTime else { return 0 }
        return minutesBetween(ArrivalTime, ArrivalRealTime)
    }

    func getTimeDifferenceDeparture() -> Int {
        guard let DepartureRealTime else { return 0 }
        return minutesBetween(DepartureTime, DepartureRealTime)
    }

    func getStop() -> Stop? {
        return stops.first { stop in
            return String(stop.stopID) == self.DataId
        }
    }

    func getPlatform() -> String? {
        switch Platform?.type {
        case "Railtrack":
            return "Gleis \(Platform?.Name ?? "0")"
        case "Platform":
            return "Steig \(Platform?.Name ?? "0")"
        default:
            return nil
        }
    }
}
