//
//  StopSequence.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 25.03.25.
//
import Foundation

struct StopSequenceItem: Hashable, Codable {
    // var isGlobalId: Bool?
    var id: String
    var name: String
    // var disassembledName: String?
    // var type: String
    // var pointType: String?
    // var coord: [Int]?
    // var niveau: Int
    var parent: Location
    // var productClasses: [Int]
    var properties: properties
    struct properties: Hashable, Codable {
        // var AREA_NIVEAU_DIVA: String
        // var DestinationText: String
        // var stoppingPointPlanned: String?
        // var areaGid: String?
        // var area: String
        // var platform: String?
        var platfromName: String?
        var plannedPlatformName: String?
    }
    var arrivalTimePlanned: Date?
    var departureTimePlanned: Date?
    var arrivalTimeEstimated: Date?
    var departureTimeEstimated: Date?

    var timetabledTime: Date? {
        departureTimePlanned ?? arrivalTimePlanned
    }

    var estimatedTime: Date? {
        departureTimeEstimated ?? arrivalTimeEstimated
    }

    func getScheduledTime() -> String {
        getTimeStamp(date: timetabledTime ?? .now)
    }

    func getRealTime() -> String {
        getTimeStamp(date: estimatedTime ?? timetabledTime ?? .now)
    }

    func getTimeDifference() -> Int {
        guard let estimatedTime, let timetabledTime else { return 0 }
        return minutesBetween(timetabledTime, estimatedTime)
    }

    func getPlatform() -> String {
        if self.properties.plannedPlatformName == nil && self.properties.platfromName == nil {
            return ""
        }

        if self.properties.platfromName != nil {
            return "Steig \(self.properties.platfromName!)"
        }

        return "Steig \(self.properties.plannedPlatformName!)"
    }

    func getStop() -> Stop? {
        return stops.first { stop in
            return String(stop.stopID) == self.parent.properties?.stopId
        }
    }
}

struct StopSequenceContainer: Hashable, Codable {
    var leg: leg
    struct leg: Hashable, Codable {
        var transportation: Transportation
        var stopSequence: [StopSequenceItem]?
    }
}
