//
//  DepartureRow.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI
import HaltestellenmonitorKit

struct DepartureRow: View {
    var stopEvent: StopEvent

    var body: some View {
        VStack(alignment: .leading) {
            Text(stopEvent.getName())
                .lineLimit(1)
            Spacer() // prevent shifiting if delayed
            HStack {
                Text(stopEvent.getScheduledTime())
                if stopEvent.getTimeDifference() > 0 {
                    Text("+\(stopEvent.getTimeDifference())")
                        .foregroundColor(Color.red)
                } else if stopEvent.getTimeDifference() < 0 {
                    Text("\(stopEvent.getTimeDifference())")
                        .foregroundColor(Color.green)
                }
                Spacer()
                Text(stopEvent.getEstimatedTime())
            }
            .font(.footnote)
            HStack {
                if stopEvent.location.properties?.platform != nil {
                    Text(stopEvent.getPlatform())
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if stopEvent.isCancelled ?? false {
                    Text("Fahrt fällt aus")
                        .foregroundColor(Color.red)
                } else {
                    Text("in \(stopEvent.getIn()) min")
                }
            }
            .font(.footnote)
        }
    }
}

/*struct DepartureRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            DepartureRow(departure: departureM.Departures[4])
        }
    }
}*/
