//
//  PartialRoute.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import Foundation
import SwiftUI

public struct PartialRoute: Hashable, Codable {
    public var Mot: Mot
    public var RegularStops: [RegularStop]?

    public init(Mot: Mot, RegularStops: [RegularStop]? = nil) {
        self.Mot = Mot
        self.RegularStops = RegularStops
    }

    public func getName() -> String {
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

    public func hasNoTime() -> Bool {
        return getStartTimeString() == nil || getEndTimeString() == nil
    }

    public func getNameShort() -> String {
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

    public func getIconText() -> Text {
        let icon = getIconVVO(motType: self.Mot.type)
        if icon == getIconStandard(motType: .Walking) {
            return Text(Image(systemName: "figure.walk"))
        }
        return Text(icon)
    }

    public func getColor() -> Color {
        getColorVVO(motType: self.Mot.type)
    }

    public func getAccessibilityLabel() -> String {
        getAccessibilityLabelVVO(motType: self.Mot.type)
    }

    public func getStartTime() -> Date? {
        guard let regularStop = RegularStops?.first else { return nil }
        return regularStop.DepartureRealTime ?? regularStop.DepartureTime
    }

    public func getStartTimeString() -> String? {
        getStartTime().map { getTimeStamp(date: $0) }
    }

    public func getEndTime() -> Date? {
        guard let regularStop = RegularStops?.last else { return nil }
        return regularStop.ArrivalRealTime ?? regularStop.ArrivalTime
    }

    public func getEndTimeString() -> String? {
        getEndTime().map { getTimeStamp(date: $0) }
    }

    public func getLastStation() -> String? {
        return self.RegularStops?.last?.Name
    }

    public func getFirstPlatform() -> String? {
        return RegularStops?.first?.getPlatform()
    }

    public func getLastPlatform() -> String? {
        return RegularStops?.last?.getPlatform()
    }

    public func getDuration() -> Int {
        let start: Double = getStartTime()?.timeIntervalSince1970 ?? 0
        let end: Double = getEndTime()?.timeIntervalSince1970 ?? 0
        return Int((end - start) / 60)
    }
}
