//
//  Location.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 27.02.25.
//

public struct Location: Hashable, Codable {
    public var id: String?
    // var isGlobalId: Bool?
    public var name: String
    public var disassembledName: String?
    public var type: String
    public var coord: [Int]?
    public var properties: Stop_Property?
    // var parent: Location?
}
