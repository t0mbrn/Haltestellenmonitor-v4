//
//  ActivityRequest.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import Foundation

public struct ActivityRequest: Hashable, Codable {
    public var token: String
    public var stopID: String
    public var line: String
    public var tripCode: String
    public var date: String
    public var time: String

    public init(token: String, stopID: String, line: String, tripCode: String, date: String, time: String) {
        self.token = token
        self.stopID = stopID
        self.line = line
        self.tripCode = tripCode
        self.date = date
        self.time = time
    }
}
