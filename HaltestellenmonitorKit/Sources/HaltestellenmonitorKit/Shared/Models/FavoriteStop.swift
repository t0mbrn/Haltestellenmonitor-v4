//
//  FavoriteStop.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation

@MainActor public class FavoriteStop: ObservableObject {
    @Published public var favorites: [Int]

    public init() {
        if let data = UserDefaults(suiteName: "group.eu.hanashi.Haltestellenmonitor")?.data(forKey: "FavoriteStops") {
            if let decoded = try? JSONDecoder().decode([Int].self, from: data) {
                favorites = decoded
                return
            }
        }

        self.favorites = []
    }

    public func add(stopID: Int) {
        if !isFavorite(stopID: stopID) {
            favorites.append(stopID)
            save()
        }
    }

    public func remove(stopID: Int) {
        if let firstIndex = favorites.firstIndex(of: stopID) {
            favorites.remove(at: firstIndex)
            save()
        }
    }

    public func isFavorite(stopID: Int) -> Bool {
        let cons = favorites.contains { element in
            if element == stopID {
                return true
            } else {
                return false
            }
        }
        return cons
    }

    public func save() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults(suiteName: "group.eu.hanashi.Haltestellenmonitor")?.set(encoded, forKey: "FavoriteStops")
        }
        // fürs Widget

        let sharedUserDefaults = UserDefaults(suiteName: "group.eu.hanashi.Haltestellenmonitor")
        sharedUserDefaults?.set(favorites, forKey: "WidgetFavs")

    }
}
