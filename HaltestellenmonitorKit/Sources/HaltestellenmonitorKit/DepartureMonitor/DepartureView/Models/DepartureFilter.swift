//
//  DapertureFilter.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import Foundation

public class DepartureFilter: ObservableObject {

    public init() {}
    @Published public var tram = true
    @Published public var bus = true
    @Published public var suburbanRailway = true
    @Published public var train = true
    @Published public var cableway = true
    @Published public var ferry = true
}
