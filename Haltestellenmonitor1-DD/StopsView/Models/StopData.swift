//
//  StopData.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation

var stops: [Stop] = load("stops.json")
var tripTmp: Trip = load("trip.json", decoder: .vvo)

func load<T: Decodable>(_ filename: String, decoder: JSONDecoder = JSONDecoder()) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
