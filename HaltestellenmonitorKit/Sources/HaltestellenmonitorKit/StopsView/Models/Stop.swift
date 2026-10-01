//
//  Stop.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation
import CoreLocation

public struct Stop: Hashable, Codable, Identifiable {
    public let id = UUID()

    public var stopID: Int
    public var gid: String
    public var name: String
    public var place: String
    public var x: String
    public var y: String

    public var distance: Double?
    public var isFavorite: Bool?

    public var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: Double(self.y) ?? 0, longitude: Double(self.x) ?? 0)
    }

    public func getDistance() -> Int {
        return Int(distance ?? 0)
    }

    private enum CodingKeys: String, CodingKey {
        case stopID, gid, name, place, x, y
    }

    public func getFullName() -> String {
        return "\(name) \(place)"
    }

    public func getName() -> String {
        return name
    }

    public static func getBystopID(stopID: String) -> Stop? {
        return stops.first { stop in
            return stopID == String(stop.stopID)
        }
    }

    public static func getByGID(gid: String) -> Stop? {
        return stops.first { stop in
            return gid == stop.gid
        }
    }
}
