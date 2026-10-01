//
//  PartialRoute.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation
import SwiftUI

struct PartialRoute: Hashable, Codable {
    var Mot: Mot
    var RegularStops: [RegularStop]?

    func getName() -> String {
        if self.Mot.type == "InsertedWaiting" {
            return "Wartezeit"
        }
        if self.Mot.type == "Footpath" {
            return hasNoTime() ? "Warten" : "Fußweg"
        }
        if self.Mot.type == "MobilityStairsUp" {
            return "aufwärts führende Treppe"
        }
        if self.Mot.type == "MobilityStairsDown" {
            return "abwärts führende Treppe"
        }
        if self.Mot.Name != nil && self.Mot.Direction == nil {
            return self.Mot.Name!
        }
        if self.Mot.Name == nil && self.Mot.Direction != nil {
            return self.Mot.Direction!
        }
        if self.Mot.Name == nil && self.Mot.Direction == nil {
            return "Unbekannt"
        }
        return "\(self.Mot.Name!) \(self.Mot.Direction!)"
    }

    func hasNoTime() -> Bool {
        return getStartTimeString() == nil || getEndTimeString() == nil
    }

    func getNameShort() -> String {
        if self.Mot.type == "InsertedWaiting" {
            return "🕝"
        }
        if self.Mot.type == "Footpath" {
            return hasNoTime() ? "🕝" : "🚶"
        }
       /* if (self.Mot.type == "MobilityStairsUp") {
            return "↑"
        }
        if (self.Mot.type == "MobilityStairsDown") {
            return "↓"
        }*/
        if self.Mot.Name != nil && self.Mot.Direction == nil {
            return self.Mot.Name!
        }
        if self.Mot.Name == nil && self.Mot.Direction != nil {
            return self.Mot.Direction!
        }
        if self.Mot.Name == nil && self.Mot.Direction == nil {
            return "Unbekannt"
        }
        return "\(self.Mot.Name!)"
    }

    func getIconText() -> Text {
        let icon = getIconVVO(motType: self.Mot.type)
        if icon == getIconStandard(motType: .Walking) {
            return Text(Image(systemName: "figure.walk"))
        }
        return Text(icon)
    }

    func getColor() -> Color {
        getColorVVO(motType: self.Mot.type)
    }

    func getAccessibilityLabel() -> String {
        getAccessibilityLabelVVO(motType: self.Mot.type)
    }

    func getStartTime() -> Date? {
        guard let regularStop = RegularStops?.first else { return nil }
        return regularStop.DepartureRealTime ?? regularStop.DepartureTime
    }

    func getStartTimeString() -> String? {
        getStartTime().map { getTimeStamp(date: $0) }
    }

    func getEndTime() -> Date? {
        guard let regularStop = RegularStops?.last else { return nil }
        return regularStop.ArrivalRealTime ?? regularStop.ArrivalTime
    }

    func getEndTimeString() -> String? {
        getEndTime().map { getTimeStamp(date: $0) }
    }

    func getLastStation() -> String? {
        return self.RegularStops?.last?.Name
    }

    func getFirstPlatform() -> String? {
        return RegularStops?.first?.getPlatform()
    }

    func getLastPlatform() -> String? {
        return RegularStops?.last?.getPlatform()
    }

    func getDuration() -> Int {
        let start: Double = getStartTime()?.timeIntervalSince1970 ?? 0
        let end: Double = getEndTime()?.timeIntervalSince1970 ?? 0
        return Int((end - start) / 60)
    }
}
