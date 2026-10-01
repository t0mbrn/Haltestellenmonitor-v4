//
//  Mot.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

public struct Mot: Hashable, Codable {
    public var type: String
    public var Name: String?
    public var Direction: String?

    public init(type: String, Name: String? = nil, Direction: String? = nil) {
        self.type = type
        self.Name = Name
        self.Direction = Direction
    }

    private enum CodingKeys: String, CodingKey {
        case type = "Type", Name, Direction
    }
}
