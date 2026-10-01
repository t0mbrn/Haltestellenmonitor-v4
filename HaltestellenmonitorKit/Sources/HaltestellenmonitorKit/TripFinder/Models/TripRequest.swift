//
//  TripRequest.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

public struct TripRequest: Hashable, Codable {
    public var time: String?
    public var isarrivaltime: Bool? = false
    public var shorttermchanges: Bool? = true
    public var origin: String
    public var destination: String
    public var standardSettings: TripStandardSettings?
    public var previous: Bool?
    public var numberprev: Int?
    public var numbernext: Int?
    public var sessionId: String?
    public var format: String = "json"

    public init(time: String? = nil, isarrivaltime: Bool? = false, shorttermchanges: Bool? = true, origin: String, destination: String, standardSettings: TripStandardSettings? = nil, previous: Bool? = nil, numberprev: Int? = nil, numbernext: Int? = nil, sessionId: String? = nil, format: String = "") {
        self.time = time
        self.isarrivaltime = isarrivaltime
        self.shorttermchanges = shorttermchanges
        self.origin = origin
        self.destination = destination
        self.standardSettings = standardSettings
        self.previous = previous
        self.numberprev = numberprev
        self.numbernext = numbernext
        self.sessionId = sessionId
        self.format = format
    }
}
