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
struct Product: Hashable, Codable {
    // var id: Int
    // var `class`: Int
    var name: String
    var iconId: Int
}
// struct Operator: Hashable, Codable {
//    var code: String
//    var id: String
//    var name: String
// }

struct Place: Hashable, Codable {
    var id: String
    var name: String
    var type: String
}

struct Stop_Property: Hashable, Codable {
    var occupancy: String?
    var stopId: String
    var area: String?
    var platform: String?
    var platformName: String?
    var plannedPlatformName: String?
}

struct T_Properties: Hashable, Codable {
    var trainName: String?
    var trainType: String?
    var trainNumber: String?
    var tripCode: Int?
    // var lineDisplay: String?
    // var isSTT: Bool?
    var globalId: String?
    // var operatorUrl: String?
    // var timetablePeriod: String?
    var specialFares: String?
    // var validity: validity?
//    struct validity: Hashable, Codable {
//        var from: String
//        var to: String
//    }

}

struct Transportation: Hashable, Codable {
    var id: String
    // var name: String
    // var disassembledName: String?
    var number: String
    var product: Product
    // var `operator`: Operator?
    // var origin: Place?
    var properties: T_Properties
    var destination: Place
    
    
    // prevent optional
    enum CodingKeys: String, CodingKey {
        case id, number, product, properties, destination
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        number = try container.decodeIfPresent(String.self, forKey: .number) ?? "N/A"
        product = try container.decode(Product.self, forKey: .product)
        properties = try container.decode(T_Properties.self, forKey: .properties)
        destination = try container.decode(Place.self, forKey: .destination)
    }
    
    // Manual initializer for previews and manual creation
    init(id: String,
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

struct InfoLink: Hashable, Codable {
    var urlText: String
    var url: String
    var content: String
    var subtitle: String
    var title: String?
    var additionalText: String?
    var htmlText: String?
}
struct Info: Hashable, Codable {
    var priority: String
    // var id: String
    // var version: Int
    // var type: String
    var infoLinks: [InfoLink]
}

// Hint Struct
// struct Hint: Hashable, Codable {
//    var content: String
//    var providerCode: String
//    var url: String?
//    var type: String
// }

struct StopEvent: Hashable, Codable {

    var realtimeStatus: [String]? // ignore?
    var isCancelled: Bool?
    var isRealtimeControlled: Bool?
    var location: Location
    var departureTimePlanned: Date
    var departureTimeBaseTimetable: Date
    var departureTimeEstimated: Date?

    var transportation: Transportation

    var infos: [Info]?
    // var hints: [Hint]?
    // var properties: Stop_Property

    func hasInfos() -> Bool {
        return self.infos != nil
    }

    // func hasHints() -> Bool {
    //    return self.hints != nil
    // }

    func getName() -> String {
        // don't use for Cable Car
        if self.transportation.properties.specialFares != nil  && self.transportation.product.iconId != 9 {
            return "\(self.transportation.properties.trainType ?? "") \(self.transportation.properties.trainNumber ?? "") \(self.transportation.destination.name)"
        }
        return "\(self.transportation.number) \(self.transportation.destination.name)"
    }

    func getIconAccessabilityLabel() -> String {
        return getAccessibilityLabelEFA(iconId: self.transportation.product.iconId)
    }

    func getIcon() -> String {
        return getIconEFA(iconId: self.transportation.product.iconId)
    }

    func getColor() -> Color {
        getColorEFA(iconId: self.transportation.product.iconId)
    }

    var departureTime: Date {
        departureTimeEstimated ?? departureTimePlanned
    }

    func getScheduledTime() -> String {
        getTimeStamp(date: departureTimePlanned)
    }

    func getEstimatedTime() -> String {
        getTimeStamp(date: departureTime)
    }

    func getTimeDifference() -> Int {
        guard let departureTimeEstimated else { return 0 }
        return minutesBetween(departureTimePlanned, departureTimeEstimated)
    }

    func getIn(date: Date = Date(), realInTime: Bool = false) -> Int {
        let inTime = minutesBetween(date, departureTime)
        return realInTime ? inTime : max(inTime, 0)
    }

    func getPlatform() -> String {
        if self.location.type == "platform" && self.location.disassembledName != nil {
            
            if [2,6].contains(self.transportation.product.iconId) {
                return "Gleis " + self.location.disassembledName!
            }
            return "Steig " + self.location.disassembledName!
        }
        return ""
    }
}

struct StopEventContainer: Hashable, Codable {
//    var version: String
    // var locations: [Location]
    var stopEvents: [StopEvent]?
}
