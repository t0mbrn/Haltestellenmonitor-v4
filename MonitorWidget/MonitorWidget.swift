//
//  MonitorWidget.swift
//  MonitorWidget
//
//  Created by Peter Lohse on 19.04.23.
//  Modiefied by Tom Braune on 03.11.23.
//  Credit to https://github.com/AKORA-Studios for helping with the LocationManager
//

import WidgetKit
import SwiftUI
import CoreLocation
import MapKit
import HaltestellenmonitorKit

class Provider: AppIntentTimelineProvider {

    typealias Entry = MonitorEntry

    let widgetLocationManager = WidgetLocationManager()

    func placeholder(in context: Context) -> MonitorEntry {
        MonitorEntry(date: Date(), configuration: ConfigurationAppIntent(), stop: nil, stopEvents: nil)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> MonitorEntry {
        // TODO: stopEvents
        MonitorEntry(date: Date(), configuration: configuration, stop: stops[0], stopEvents: [])
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<MonitorEntry> {
        let stop = await resolveStop(for: configuration)

        guard let stopEvents = try? await fetchDepartures(stopId: stop.gid) else {
            print("Widget: departure request failed")
            let entry = MonitorEntry(date: .now, configuration: configuration, stop: stop, stopEvents: nil)
            return Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(60)))
        }

        let entries = (0 ..< 72).map { index in
            MonitorEntry(date: .now.addingTimeInterval(30 * Double(index)), configuration: configuration, stop: stop, stopEvents: stopEvents)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }

    private func resolveStop(for configuration: ConfigurationAppIntent) async -> Stop {
        let fallback = Stop.getByGID(gid: "de:14612:28")!

        guard configuration.favoriteFilter == .true else {
            return Stop.getBystopID(stopID: configuration.stopType?.id ?? "0") ?? fallback
        }

        var favoriteStops: [Int] = []
        if let data = UserDefaults(suiteName: "group.eu.hanashi.Haltestellenmonitor")?.data(forKey: "FavoriteStops"),
           let decoded = try? JSONDecoder().decode([Int].self, from: data) {
            favoriteStops = decoded
        }
        let favStops = stops.filter { favoriteStops.contains($0.stopID) }
        if favStops.isEmpty {
            print("Widget: No favorites found.")
            return fallback
        }

        // Dresden town hall GPS coordinates as default
        let location = await widgetLocationManager.fetchLocation() ?? CLLocation(latitude: +51.04750, longitude: +13.74035)
        return favStops.min {
            location.distance(from: CLLocation(latitude: $0.coordinates.latitude, longitude: $0.coordinates.longitude)) <
            location.distance(from: CLLocation(latitude: $1.coordinates.latitude, longitude: $1.coordinates.longitude))
        }!
    }
}

struct MonitorWidget: Widget {
    let kind: String = "MonitorWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            MonitorWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Haltestellenmonitor")
        .description("Widget zur Anzeige der Abfahrten an einer Haltestelle.")
        .contentMarginsDisabled()
    }
}
