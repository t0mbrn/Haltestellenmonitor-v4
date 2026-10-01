//
//  StopSequence.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 25.03.25.
//
import Foundation

public struct StopSequenceItem: Hashable, Codable {
    // var isGlobalId: Bool?
    public var id: String
    public var name: String
    // var disassembledName: String?
    // var type: String
    // var pointType: String?
    // var coord: [Int]?
    // var niveau: Int
    public var parent: Location
    // var productClasses: [Int]
    public var properties: properties
    public struct properties: Hashable, Codable {
        // var AREA_NIVEAU_DIVA: String
        // var DestinationText: String
        // var stoppingPointPlanned: String?
        // var areaGid: String?
        // var area: String
        // var platform: String?
        public var platfromName: String?
        public var plannedPlatformName: String?
    }
    public var arrivalTimePlanned: Date?
    public var departureTimePlanned: Date?
    public var arrivalTimeEstimated: Date?
    public var departureTimeEstimated: Date?

    public var timetabledTime: Date? {
        departureTimePlanned ?? arrivalTimePlanned
    }

    public var estimatedTime: Date? {
        departureTimeEstimated ?? arrivalTimeEstimated
    }

    public func getScheduledTime() -> String {
        getTimeStamp(date: timetabledTime ?? .now)
    }

    public func getRealTime() -> String {
        getTimeStamp(date: estimatedTime ?? timetabledTime ?? .now)
    }

    public func getTimeDifference() -> Int {
        guard let estimatedTime, let timetabledTime else { return 0 }
        return minutesBetween(timetabledTime, estimatedTime)
    }

    public func getPlatform() -> String {
        if self.properties.plannedPlatformName == nil && self.properties.platfromName == nil {
            return ""
        }

        if self.properties.platfromName != nil {
            return "Steig \(self.properties.platfromName!)"
        }

        return "Steig \(self.properties.plannedPlatformName!)"
    }

    public func getStop() -> Stop? {
        return stops.first { stop in
            return String(stop.stopID) == self.parent.properties?.stopId
        }
    }
}

public struct StopSequenceContainer: Hashable, Codable {
    public var leg: leg
    public struct leg: Hashable, Codable {
        public var transportation: Transportation
        public var stopSequence: [StopSequenceItem]?
    }
}
