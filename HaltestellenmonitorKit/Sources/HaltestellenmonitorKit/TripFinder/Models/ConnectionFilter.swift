//
//  ConnectionFilter.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation

public class ConnectionFilter: ObservableObject {
    @Published public var startStop: ConnectionStop?
    @Published public var endStop: ConnectionStop?

    public init() {}
    @Published public var start = false
}
