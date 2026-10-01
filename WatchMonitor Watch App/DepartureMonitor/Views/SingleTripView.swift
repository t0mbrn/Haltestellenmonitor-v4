//
//  SingleTripView.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI

struct SingleTripView: View {
    @State var stopSequence: [StopSequenceItem] = []
    @State private var isLoaded = false
    @State private var searchText = ""
    var stop: Stop
    var stopEvent: StopEvent

    var body: some View {
        Group {
            if isLoaded {
                List(searchResults, id: \.self) { stopSequenceItem in
                    NavigationLink {
                        DepartureView(stop: stopSequenceItem.getStop() ?? stop)
                    } label: {
                        SingleTripRow(stopSequenceItem: stopSequenceItem)
                    }
                }
                .searchable(text: $searchText)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(stopEvent.getName())
        .task(id: stopEvent.transportation.properties.globalId, priority: .userInitiated) {
            await getSingleTrip()

            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(30))
                    if !Task.isCancelled {
                        await getSingleTrip()
                    }
                } catch {
                    // Task was cancelled
                    break
                }
            }
        }
    }

    var searchResults: [StopSequenceItem] {
        if searchText.isEmpty {
            return stopSequence
        } else {
            return stopSequence.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    func getSingleTrip() async {
        do {
            let stopEvents = try await fetchStopSequence(stop: stop, stopEvent: stopEvent)
            await MainActor.run {
                if stopEvents.count > 0 {
                    self.stopSequence = stopEvents
                }
                self.isLoaded = true
            }
        } catch {
            if !Task.isCancelled {
                print("SingleTrip error: \(error)")
                do {
                    try await Task.sleep(for: .seconds(1))
                    if !Task.isCancelled {
                        await getSingleTrip()
                    }
                } catch {
                    // Task was cancelled during sleep
                    return
                }
            }
        }
    }
}

/*struct SingleTripView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SingleTripView(stop: stops[0], departure: departureM.Departures[0])
        }
    }
}*/
