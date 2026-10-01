//
//  DepartureView.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI
import HaltestellenmonitorKit

struct DepartureView: View {
    var stop: Stop
    @State private var searchText = ""
    @State private var stopEvents: [StopEvent] = []
    @State private var isLoaded = false

    var body: some View {
        Group {
            if isLoaded {
                List(searchResults.sorted { $0.departureTime < $1.departureTime }, id: \.self) { stopEvent in
                    NavigationLink {
                        SingleTripView(stop: stop, stopEvent: stopEvent)
                    } label: {
                        DepartureRow(stopEvent: stopEvent)
                    }
                }
                .searchable(text: $searchText)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(stop.name)
        .task(id: stop.id, priority: .userInitiated) {
            await getDeparture()

            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(30))
                    if !Task.isCancelled {
                        await getDeparture()
                    }
                } catch {
                    // Task was cancelled
                    break
                }
            }
        }
    }

    var searchResults: [StopEvent] {
        let departures = stopEvents

        if searchText.isEmpty {
            return departures
        } else {
            return departures.filter {
                $0.getName().contains(searchText)
            }
        }
    }

    func getDeparture() async {
        do {
            let stopEvents = try await fetchDepartures(stopId: stop.gid)
            await MainActor.run {
                self.stopEvents = stopEvents
                self.isLoaded = true
            }
        } catch {
            if !Task.isCancelled {
                print("Watch DepartureMonitor error: \(error)")
                do {
                    try await Task.sleep(for: .seconds(1))
                    if !Task.isCancelled {
                        await getDeparture()
                    }
                } catch {
                    // Task was cancelled during sleep
                    return
                }

            }
        }
    }
}

// struct DepartureView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            DepartureView(stop: stops[0])
//        }
//    }
// }
