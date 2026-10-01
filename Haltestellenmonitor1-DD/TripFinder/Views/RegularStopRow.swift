//
//  RegularStopRow.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 21.04.23.
//

import SwiftUI

struct RegularStopRow: View {
    var regularStop: RegularStop
    var isFirst: Bool

    // first stop of a leg shows departure, the others arrival
    private var kind: String { isFirst ? "Abfahrt" : "Ankunft" }
    private var plannedTime: String { isFirst ? regularStop.getDepartureTime() : regularStop.getArrivalTime() }
    private var realTime: String { isFirst ? regularStop.getRealDepartureTime() : regularStop.getRealArrivalTime() }
    private var delay: Int { isFirst ? regularStop.getTimeDifferenceDeparture() : regularStop.getTimeDifference() }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(regularStop.Name)
                    .accessibilityLabel("Haltestelle \(regularStop.Name)")
                Spacer()
                if regularStop.getPlatform() != nil {
                    Text(regularStop.getPlatform() ?? "")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .accessibilitySortPriority(-1)
                }
            }
            HStack {
                Text("\(plannedTime) Uhr")
                    .accessibilityLabel("Geplante \(kind) \(plannedTime) Uhr")
                if delay > 0 {
                    Text("+\(delay)")
                        .foregroundColor(Color.red)
                        .accessibilityLabel("\(delay) \(delay == 1 ? "Minute" : "Minuten") Verspätung")
                } else if delay < 0 {
                    Text("\(delay)")
                        .foregroundColor(Color.green)
                        .accessibilityLabel("\(abs(delay)) \(delay == -1 ? "Minute" : "Minuten") früher")
                }
                Spacer()
                Text("\(realTime) Uhr")
                    .accessibilityLabel("Voraussichtliche \(kind) \(realTime) Uhr")
            }
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }
}

/*struct RegularStopRow_Previews: PreviewProvider {
    static var previews: some View {
        RegularStopRow(regularStop: tripTmp.Routes[0].PartialRoutes[0].RegularStops![0], isFirst: true)
    }
}*/
