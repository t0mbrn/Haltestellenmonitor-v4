//
//  MonitorWidgetEntryView.swift
//  MonitorWidgetExtension
//
//  Created by Peter Lohse on 19.04.23.
//  Modified by Tom Braune on 03.11.23.
//

import WidgetKit
import SwiftUI
import CoreLocation
import HaltestellenmonitorKit

struct MonitorWidgetEntryView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    private var departures: [StopEvent] {
        let count = (widgetFamily == .systemLarge || widgetFamily == .systemExtraLarge) ? 16 : 5
        return Array(entry.filterStopEvents(stopEvents: entry.stopEvents ?? []).sorted { $0.departureTime < $1.departureTime }.prefix(count))
    }

    private var stopURL: URL? {
        URL(string: "widget://stop/\(String(entry.stop?.stopID ?? 0).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(entry.stop?.getName() ?? "")
                    .font(.headline)
                    .padding(.bottom, 1.0)
                if departures.isEmpty {
                    Text("Es wurden keine Abfahrten gefunden.")
                        .font(.subheadline)
                } else {
                    ForEach(departures) { stopEvent in
                        MonitorWidgetRow(entry: entry, stopEvent: stopEvent)
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .padding([.top, .leading, .bottom])
        .padding(.trailing, 5.0)
        .containerBackground(colorScheme == .dark ? Color.black : Color.yellow, for: .widget)
        .widgetURL(stopURL)
        .dynamicTypeSize(.medium ... .large)
    }
}

// struct MonitorWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        MonitorWidgetEntryView(entry: MonitorEntry(date: Date(), configuration: ConfigurationIntent(), departureMonitor: departureM))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//            .previewDisplayName("Small")
//        
//        MonitorWidgetEntryView(entry: MonitorEntry(date: Date(), configuration: ConfigurationIntent(), departureMonitor: departureM))
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//            .previewDisplayName("Medium")
//        
//        MonitorWidgetEntryView(entry: MonitorEntry(date: Date(), configuration: ConfigurationIntent(), departureMonitor: departureM))
//            .previewContext(WidgetPreviewContext(family: .systemLarge))
//            .previewDisplayName("Large")
//        
//        MonitorWidgetEntryView(entry: MonitorEntry(date: Date(), configuration: ConfigurationIntent(), departureMonitor: departureM))
//            .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
//            .previewDisplayName("Extra Large")
//    }
// }
