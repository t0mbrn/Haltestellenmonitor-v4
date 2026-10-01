//
//  StopData.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation

public var stops: [Stop] = load("stops.json", bundle: .module)

public func load<T: Decodable>(_ filename: String, bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) -> T {
    let data: Data

    guard let file = bundle.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in \(bundle.bundlePath).")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename):\n\(error)")
    }

    do {
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
