//
//  DepartureView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import SwiftUI
import ActivityKit

struct DepartureView: View {
    var stop: Stop
    @EnvironmentObject var favoriteStops: FavoriteStop
    @EnvironmentObject var pushTokenHistory: PushTokenHistory
    @State var stopEvents: [StopEvent] = []
    @State private var searchText = ""
    @State private var isLoaded = false
    @State private var dateTime = Date.now
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var isLoadingMore = false
    @State private var reachedEnd = false
    @StateObject var departureFilter = DepartureFilter()

    var body: some View {
        Group {
            if isLoaded {
                loadedForm
            } else {
                skeletonForm
            }
        }
        .refreshable {
            if dateTime < Date.now {
                dateTime = Date.now
            }
            await getDeparture()
        }
        .navigationTitle(Text("🚏 \(stop.name)").accessibilityLabel("Haltestelle \(stop.name)"))
        .toolbar {
            Button {
                if favoriteStops.isFavorite(stopID: stop.stopID) {
                    favoriteStops.remove(stopID: stop.stopID)
                } else {
                    favoriteStops.add(stopID: stop.stopID)
                }
            } label: {
                if favoriteStops.isFavorite(stopID: stop.stopID) {
                    Label("Als Favorit entfernen", systemImage: "star.fill")
                } else {
                    Label("Als Favorit hinzufügen", systemImage: "star")
                }
            }
        }
        .alert("Diese Abfahrt wird nun als Live-Aktivität angezeigt.", isPresented: $showingSuccessAlert) {
            Button {
                // do nothing
            } label: {
                Text("OK")
            }
        }
        .alert("Die Live-Aktivität wurde nicht korrekt registriert. Sie wird nicht aktualisiert.", isPresented: $showingErrorAlert) {
            Button {
                // do nothing
            } label: {
                Text("OK")
            }
        }

        .task(id: stop.id, priority: .userInitiated) {
            await getDeparture(reset: true)

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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: dateTime) {
            Task {
                await getDeparture(reset: true)
            }
        }
        .environmentObject(departureFilter)
    }

    // Split into separate properties: one big body took >200 ms to type-check.

    private var loadedForm: some View {
        let departures = searchResults.sorted { $0.departureTime < $1.departureTime }
        // start loading the next page while ~10 rows are still left to scroll
        let prefetchID = departures.dropLast(10).last?.id ?? departures.first?.id

        return Form {
            Section {
                DisclosureGroup("Verkehrsmittel") {
                    DepartureDisclosureSection()
                }
                HStack {
                    DatePicker(selection: $dateTime, in: Date()...) {
                        Text("Zeit").accessibilityHint("Bei Bedarf hier gewünschten Zeitpunkt einstellen")
                    }

                    Button {
                        dateTime = Date.now
                    } label: {
                        Text("Jetzt")
                            .accessibilityHint("Auf aktuellen Zeitpunkt zurücksetzen")
                    }
                }
            }
            Section {
                ForEach(departures) { stopEvent in
                    departureRow(stopEvent)
                        .onAppear {
                            if stopEvent.id == prefetchID {
                                Task { await loadMore() }
                            }
                        }
                }
            }
            if !reachedEnd {
                loadMoreSection
            }
        }
    }

    private func departureRow(_ stopEvent: StopEvent) -> some View {
        ZStack {
            NavigationLink {
                SingleTripView(stop: stop, stopEvent: stopEvent)
            } label: {
                EmptyView()
            }
            .opacity(0.0)
            .buttonStyle(.plain)

            DepartureRow(stopEvent: stopEvent)
        }
        .swipeActions(edge: .trailing) {
            if !ProcessInfo().isiOSAppOnMac {
                Button {
                    startActivity(stopEvent: stopEvent)
                } label: {
                    Label("", systemImage: "pin")
                }
                .tint(.yellow)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Zeige \(stopEvent.hasInfos() ? "Meldungen & " : "")nächste Haltestellen dieser Linie")
    }

    private var loadMoreSection: some View {
        Section {
            // fallback when the list is too short to scroll (e.g. strict filters)
            Button {
                Task { await loadMore() }
            } label: {
                if isLoadingMore {
                    ProgressView()
                } else {
                    Text("Spätere Abfahrten laden")
                }
            }
            .frame(maxWidth: .infinity)
            .disabled(isLoadingMore)
            .onAppear {
                Task { await loadMore() }
            }
        }
    }

    private var skeletonForm: some View {
        Form {
            Section {
                DisclosureGroup("Verkehrsmittel") {
                    DepartureDisclosureSection()
                }

                HStack {
                    DatePicker("Zeit", selection: $dateTime)

                    Button {
                        dateTime = Date.now
                    } label: {
                        Text("Jetzt")
                    }
                }
            }
            .disabled(true)
            .accessibilityHint("Warte auf Daten")
            Section {
                ForEach(0..<9, id: \.self) { _ in
                    DepartureRowSkeleton()
                }
            }
        }
    }

    var searchResults: [StopEvent] {
        var stopEventsTmp = stopEvents
        stopEventsTmp = stopEventsTmp.filter {
            (departureFilter.tram && $0.transportation.product.iconId == 4) ||
            (departureFilter.bus && $0.transportation.product.iconId == 3) ||
            (departureFilter.suburbanRailway && $0.transportation.product.iconId == 2) ||
            (departureFilter.train && $0.transportation.product.iconId == 6) ||
            (departureFilter.cableway && $0.transportation.product.iconId == 9) ||
            (departureFilter.ferry && $0.transportation.product.iconId == 10)
        }

        if searchText.isEmpty {
            return stopEventsTmp
        } else {
            return stopEventsTmp.filter {
                $0.getName().lowercased().contains(searchText.lowercased())
            }
        }
    }

    /// Loads the first page. `reset` replaces the list; otherwise pages appended by scrolling are kept.
    func getDeparture(reset: Bool = false) async {
        let localDateTime = max(dateTime, .now)

        do {
            let firstPage = try await fetchDepartures(stopId: stop.gid, date: localDateTime)
            await MainActor.run {
                if reset {
                    self.stopEvents = firstPage
                    self.reachedEnd = false
                } else {
                    self.stopEvents = mergeFirstPage(firstPage, into: self.stopEvents)
                }
                self.isLoaded = true
            }

        } catch {
            if !Task.isCancelled {
                print("DepartureMonitor error: \(error)")
                do {
                    try await Task.sleep(for: .seconds(1))
                    if !Task.isCancelled {
                        await getDeparture(reset: reset)
                    }
                } catch {
                    // Task was cancelled during sleep
                    return
                }
            }
        }
    }

    /// Appends the departures following the last loaded one.
    func loadMore() async {
        guard !isLoadingMore, !reachedEnd, let last = stopEvents.map(\.departureTimePlanned).max() else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        guard let page = try? await fetchDepartures(stopId: stop.gid, date: last) else { return }
        let known = Set(stopEvents.map(\.id))
        let new = page.filter { !known.contains($0.id) }
        if new.isEmpty {
            reachedEnd = true
        } else {
            stopEvents += new
        }
    }

    func startActivity(stopEvent: StopEvent) {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let state = TripAttributes.ContentState(timetabledTime: stopEvent.departureTimePlanned.ISO8601Format(), estimatedTime: stopEvent.departureTimeEstimated?.ISO8601Format())
            let attributes = TripAttributes(name: stop.name, icon: stopEvent.getIcon(), stopID: String(stop.stopID), lineRef: stopEvent.transportation.id, timetabledTime: stopEvent.departureTimePlanned.ISO8601Format(), directionRef: "outward", publishedLineName: stopEvent.transportation.number, destinationText: stopEvent.transportation.destination.name)

            let activityContent = ActivityContent(state: state, staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!)

            do {
                let activity = try Activity.request(attributes: attributes, content: activityContent, pushType: .token)
                print("Requested an activity \(String(activity.id)).")

                showingSuccessAlert = true

                Task {
                    for await data in activity.pushTokenUpdates {
                        let token = data.map {String(format: "%02x", $0)}.joined()
                        saveAcitivityOnServer(stopEvent: stopEvent, token: token)
                    }
                }
            } catch {
                print("DepartureMonitor Live Activity Start Error: \(error)")
            }
        }
    }

    func saveAcitivityOnServer(stopEvent: StopEvent, token: String) {
        if pushTokenHistory.isInHistory(token: token) {
            return
        }
        pushTokenHistory.add(token: token)

        let url = URL(string: "https://dvb.hsrv.me/api/activity_v2")!
        let date = stopEvent.departureTimePlanned
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(ActivityRequest(token: token, stopID: stop.gid, line: stopEvent.transportation.id, tripCode: String(stopEvent.transportation.properties.tripCode ?? 0), date: getDateStampURL(date: date), time: getTimeStampURL(date: date)))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Haltestellenmonitor Dresden v4", forHTTPHeaderField: "User-Agent")

        let task = URLSession.shared.dataTask(with: request) {(data, _, error) in
            guard error == nil else {
                print("DepartureMonitor Live Activity Request error: \(error!)")
                showingErrorAlert = true
                return
            }

            guard data != nil else {
                print("DepartureMonitor Live Activity Request: No data")
                showingErrorAlert = true
                return
            }
        }
        task.resume()
    }
}

 struct DepartureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DepartureView(stop: stops[100])
        }
            .environmentObject(FavoriteStop())
            .environmentObject(PushTokenHistory())
    }
 }
