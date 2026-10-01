//
//  DepartureRequest.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 23.07.24.
//

import Foundation

func createDepartureRequest(stopId: String, itdDate: String, itdTime: String) -> String {
    return "mode=direct&outputFormat=rapidJSON&type_dm=stop&useProxFootSearch=0&useRealtime=1&limit=50&lsShowTrainsExplicit=1&locationServerActive=1&useAllStops=1&name_dm=\(stopId)&itdDate=\(itdDate)&itdTime=\(itdTime)"
}

func fetchDepartures(stopId: String, date: Date = .now) async throws -> [StopEvent] {
    var request = URLRequest(url: URL(string: "https://efa.vvo-online.de/std3/trias/XML_DM_REQUEST")!, timeoutInterval: 20)
    request.httpMethod = "POST"
    request.httpBody = createDepartureRequest(stopId: stopId, itdDate: getDateStampURL(date: date), itdTime: getTimeStampURL(date: date)).data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let (content, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(StopEventContainer.self, from: content).stopEvents ?? []
}
