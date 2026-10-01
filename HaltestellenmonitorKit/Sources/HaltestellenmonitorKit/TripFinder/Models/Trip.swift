//
//  Trip.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

public struct Trip: Hashable, Codable {
    public var SessionId: String
    public var Routes: [Route]
}
