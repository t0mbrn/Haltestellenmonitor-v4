//
//  RegularStop.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

public struct RegularStop: Hashable, Codable {
    public var ArrivalTime: Date
    public var DepartureTime: Date
    public var ArrivalRealTime: Date?
    public var DepartureRealTime: Date?
    public var Place: String
    public var Name: String
    public var type: String
    public var Platform: DeparturePlatform?
    public var Latitude: Int
    public var Longitude: Int
    public var DepartureState: String?
    public var ArrivalState: String?
    public var DataId: String

    public init(ArrivalTime: Date, DepartureTime: Date, ArrivalRealTime: Date? = nil, DepartureRealTime: Date? = nil, Place: String, Name: String, type: String, Platform: DeparturePlatform? = nil, Latitude: Int, Longitude: Int, DepartureState: String? = nil, ArrivalState: String? = nil, DataId: String) {
        self.ArrivalTime = ArrivalTime
        self.DepartureTime = DepartureTime
        self.ArrivalRealTime = ArrivalRealTime
        self.DepartureRealTime = DepartureRealTime
        self.Place = Place
        self.Name = Name
        self.type = type
        self.Platform = Platform
        self.Latitude = Latitude
        self.Longitude = Longitude
        self.DepartureState = DepartureState
        self.ArrivalState = ArrivalState
        self.DataId = DataId
    }

    private enum CodingKeys: String, CodingKey {
        case ArrivalTime, DepartureTime, ArrivalRealTime, DepartureRealTime, Place, Name, type = "Type", Platform, Latitude, Longitude, DepartureState, ArrivalState, DataId
    }

    public func getArrivalTime() -> String {
        getTimeStamp(date: ArrivalTime)
    }

    public func getDepartureTime() -> String {
        getTimeStamp(date: DepartureTime)
    }

    public func getRealArrivalTime() -> String {
        getTimeStamp(date: ArrivalRealTime ?? ArrivalTime)
    }

    public func getRealDepartureTime() -> String {
        getTimeStamp(date: DepartureRealTime ?? DepartureTime)
    }

    public func getTimeDifference() -> Int {
        guard let ArrivalRealTime else { return 0 }
        return minutesBetween(ArrivalTime, ArrivalRealTime)
    }

    public func getTimeDifferenceDeparture() -> Int {
        guard let DepartureRealTime else { return 0 }
        return minutesBetween(DepartureTime, DepartureRealTime)
    }

    public func getStop() -> Stop? {
        return stops.first { stop in
            return String(stop.stopID) == self.DataId
        }
    }

    public func getPlatform() -> String? {
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
