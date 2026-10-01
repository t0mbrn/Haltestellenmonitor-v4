//
//  ConfigurationAppIntent.swift
//  MonitorWidgetExtension
//
//  Widget configuration (replaced the SiriKit intent and the MonitorIntents extension in v4).
//

import AppIntents
import WidgetKit
import HaltestellenmonitorKit

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Haltestellenmonitor"
    static var description = IntentDescription("Widget zur Anzeige der Abfahrten an einer Haltestelle.")

    @Parameter(title: "Haltestelle")
    var stopType: StopEntity?

    @Parameter(title: "Anzeige")
    var displayFormat: DisplayFormatAppEnum?

    @Parameter(title: "Linienfilter")
    var lineFilter: [LineEntity]?

    @Parameter(title: "Automatisch nächsten Favoriten anzeigen")
    var favoriteFilter: FavoriteFilterAppEnum?
}

enum DisplayFormatAppEnum: String, AppEnum {
    case minutes
    case time

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Anzeige"
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .minutes: "Abfahrt in",
        .time: "Uhrzeit"
    ]
}

enum FavoriteFilterAppEnum: String, AppEnum {
    case `true`
    case `false`

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Favorit"
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .true: "Ein",
        .false: "Gewählte Haltestelle beibehalten"
    ]
}

struct StopEntity: AppEntity {
    let id: String // stopID
    let name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Haltestelle"
    static var defaultQuery = StopEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    init(_ stop: Stop) {
        id = String(stop.stopID)
        name = stop.getFullName()
    }
}

struct StopEntityQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [StopEntity] {
        identifiers.compactMap { Stop.getBystopID(stopID: $0) }.map(StopEntity.init)
    }

    func entities(matching string: String) async throws -> [StopEntity] {
        stops.filter { $0.getFullName().localizedCaseInsensitiveContains(string) }.map(StopEntity.init)
    }

    func suggestedEntities() async throws -> [StopEntity] {
        stops.map(StopEntity.init)
    }
}

struct LineEntity: AppEntity {
    let id: String // line number

    static let all = [
        "1", "2", "3", "4", "6", "7", "8", "9", "10", "11", "12", "13", "20",
        "61", "62", "63", "64", "65", "66", "68", "70", "72", "73", "74", "76", "77", "78", "79",
        "80", "81", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93"
    ]

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Linie"
    static var defaultQuery = LineEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }
}

struct LineEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [LineEntity] {
        identifiers.map(LineEntity.init)
    }

    func suggestedEntities() async throws -> [LineEntity] {
        LineEntity.all.map(LineEntity.init)
    }
}
