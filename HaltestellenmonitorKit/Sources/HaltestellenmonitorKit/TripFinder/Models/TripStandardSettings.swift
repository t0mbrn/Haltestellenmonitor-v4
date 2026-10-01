//
//  TripStandardSettings.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import Foundation

public struct TripStandardSettings: Hashable, Codable {
    public var mot: [String]

    public init(mot: [String]) {
        self.mot = mot
    }
}
