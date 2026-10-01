//
//  DepartureRequestSingle.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 23.02.25.
//

import Foundation

func createDepartureRequestSingle(stopId: String, line: String, tripCode: Int, date: String, time: String, tStOTType: String = "NEXT") -> String {
    return "mode=direct&outputFormat=rapidJSON&useRealtime=1&limit=50&stopID=\(stopId)&tStOTType=\(tStOTType)&date=\(date)&time=\(time)&tripCode=\(tripCode)&line=\(line)"
}

func fetchStopSequence(stop: Stop, stopEvent: StopEvent) async throws -> [StopSequenceItem] {
    var request = URLRequest(url: URL(string: "https://efa.vvo-online.de/std3/trias/XML_TRIPSTOPTIMES_REQUEST")!, timeoutInterval: 20)
    request.httpMethod = "POST"
    let date = getISO8601Date(dateString: stopEvent.departureTimePlanned)
    request.httpBody = createDepartureRequestSingle(
        stopId: stop.gid,
        line: stopEvent.transportation.id,
        tripCode: stopEvent.transportation.properties.tripCode ?? 0,
        date: getDateStampURL(date: date),
        time: getTimeStampURL(date: date)
    ).data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let (content, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(StopSequenceContainer.self, from: content).leg.stopSequence ?? []
}
