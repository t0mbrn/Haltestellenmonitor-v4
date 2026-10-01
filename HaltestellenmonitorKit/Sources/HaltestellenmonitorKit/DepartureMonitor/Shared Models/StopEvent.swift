//
//  StopEvent.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 23.07.24.
//  Reworked by Tom Braune on 23.03.25.
//

import Foundation
import SwiftUI

// Transport Struct
public struct Product: Hashable, Codable {
    // var id: Int
    // var `class`: Int
    public var name: String
    public var iconId: Int
}
// struct Operator: Hashable, Codable {
//    var code: String
//    var id: String
//    var name: String
// }

public struct Place: Hashable, Codable {
    public var id: String
    public var name: String
    public var type: String
}

public struct Stop_Property: Hashable, Codable {
    public var occupancy: String?
    public var stopId: String
    public var area: String?
    public var platform: String?
    public var platformName: String?
    public var plannedPlatformName: String?
}

public struct T_Properties: Hashable, Codable {
    public var trainName: String?
    public var trainType: String?
    public var trainNumber: String?
    public var tripCode: Int?
    // var lineDisplay: String?
    // var isSTT: Bool?
    public var globalId: String?
    // var operatorUrl: String?
    // var timetablePeriod: String?
    public var specialFares: String?
    // var validity: validity?
//    struct validity: Hashable, Codable {
//        var from: String
//        var to: String
//    }

}

public struct Transportation: Hashable, Codable {
    public var id: String
    // var name: String
    // var disassembledName: String?
    public var number: String
    public var product: Product
    // var `operator`: Operator?
    // var origin: Place?
    public var properties: T_Properties
    public var destination: Place
    
    
    // prevent optional
    public enum CodingKeys: String, CodingKey {
        case id, number, product, properties, destination
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        number = try container.decodeIfPresent(String.self, forKey: .number) ?? "N/A"
        product = try container.decode(Product.self, forKey: .product)
        properties = try container.decode(T_Properties.self, forKey: .properties)
        destination = try container.decode(Place.self, forKey: .destination)
    }
    
    // Manual initializer for previews and manual creation
    public init(id: String,
         number: String = "N/A",
         product: Product,
         properties: T_Properties,
         destination: Place) {
        self.id = id
        self.number = number
        self.product = product
        self.properties = properties
        self.destination = destination
    }
}

// Info Struct

public struct InfoLink: Hashable, Codable {
    public var urlText: String
    public var url: String
    public var content: String
    public var subtitle: String
    public var title: String?
    public var additionalText: String?
    public var htmlText: String?
}
public struct Info: Hashable, Codable {
    public var priority: String
    // var id: String
    // var version: Int
    // var type: String
    public var infoLinks: [InfoLink]
}

// Hint Struct
// struct Hint: Hashable, Codable {
//    var content: String
//    var providerCode: String
//    var url: String?
//    var type: String
// }

public struct StopEvent: Hashable, Codable, Identifiable {

    public var realtimeStatus: [String]? // ignore?
    public var isCancelled: Bool?
    public var isRealtimeControlled: Bool?
    public var location: Location
    public var departureTimePlanned: Date
    public var departureTimeBaseTimetable: Date
    public var departureTimeEstimated: Date?

    public var transportation: Transportation

    public var infos: [Info]?
    // var hints: [Hint]?
    // var properties: Stop_Property

    public func hasInfos() -> Bool {
        return self.infos != nil
    }

    // func hasHints() -> Bool {
    //    return self.hints != nil
    // }

    public func getName() -> String {
        // don't use for Cable Car
        if self.transportation.properties.specialFares != nil  && self.transportation.product.iconId != 9 {
            return "\(self.transportation.properties.trainType ?? "") \(self.transportation.properties.trainNumber ?? "") \(self.transportation.destination.name)"
        }
        return "\(self.transportation.number) \(self.transportation.destination.name)"
    }

    public func getIconAccessabilityLabel() -> String {
        return getAccessibilityLabelEFA(iconId: self.transportation.product.iconId)
    }

    public func getIcon() -> String {
        return getIconEFA(iconId: self.transportation.product.iconId)
    }

    public func getColor() -> Color {
        getColorEFA(iconId: self.transportation.product.iconId)
    }

    /// Stable across realtime updates, unlike the synthesized hash.
    public var id: String {
        "\(transportation.id)|\(transportation.properties.tripCode ?? 0)|\(departureTimePlanned.timeIntervalSince1970)"
    }

    public var departureTime: Date {
        departureTimeEstimated ?? departureTimePlanned
    }

    public func getScheduledTime() -> String {
        getTimeStamp(date: departureTimePlanned)
    }

    public func getEstimatedTime() -> String {
        getTimeStamp(date: departureTime)
    }

    public func getTimeDifference() -> Int {
        guard let departureTimeEstimated else { return 0 }
        return minutesBetween(departureTimePlanned, departureTimeEstimated)
    }

    public func getIn(date: Date = Date(), realInTime: Bool = false) -> Int {
        let inTime = minutesBetween(date, departureTime)
        return realInTime ? inTime : max(inTime, 0)
    }

    public func getPlatform() -> String {
        if self.location.type == "platform" && self.location.disassembledName != nil {
            
            if [2,6].contains(self.transportation.product.iconId) {
                return "Gleis " + self.location.disassembledName!
            }
            return "Steig " + self.location.disassembledName!
        }
        return ""
    }
}

public struct StopEventContainer: Hashable, Codable {
//    var version: String
    // var locations: [Location]
    public var stopEvents: [StopEvent]?
}
