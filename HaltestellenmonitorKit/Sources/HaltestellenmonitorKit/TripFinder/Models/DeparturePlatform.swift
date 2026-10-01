//
//  DeparturePlatform.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation

public struct DeparturePlatform: Hashable, Codable {
    public var Name: String?
    public var type: String

    private enum CodingKeys: String, CodingKey {
        case Name, type = "Type"
    }
}
