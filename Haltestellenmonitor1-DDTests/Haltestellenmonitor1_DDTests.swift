//
//  Haltestellenmonitor1_DDTests.swift
//  Haltestellenmonitor1-DDTests
//
//  Created by Peter Lohse on 03.07.23.
//

import XCTest
@testable import Haltestellenmonitor1_DD

final class Haltestellenmonitor1_DDTests: XCTestCase {

    // ponytail: read fixtures next to this file instead of bundling them; works in the simulator only
    private func fixture(_ name: String) throws -> Data {
        try Data(contentsOf: URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("Fixtures/\(name)"))
    }

    private func departures() throws -> [StopEvent] {
        try JSONDecoder.efa.decode(StopEventContainer.self, from: fixture("efa_departures.json")).stopEvents ?? []
    }

    // MARK: EFA departures

    func testDecodesDepartureDates() throws {
        let events = try departures()
        XCTAssertEqual(events.count, 3)
        XCTAssertEqual(events[0].departureTimePlanned, try Date("2026-10-01T08:37:00Z", strategy: .iso8601))
        XCTAssertEqual(events[0].departureTimeEstimated, try Date("2026-10-01T08:42:18Z", strategy: .iso8601))
        XCTAssertNil(events[2].departureTimeEstimated)
    }

    func testDelay() throws {
        let events = try departures()
        XCTAssertEqual(events[0].getTimeDifference(), 5) // 08:37 -> 08:42:18
        XCTAssertEqual(events[1].getTimeDifference(), 5) // 08:38 -> 08:43:48
        XCTAssertEqual(events[2].getTimeDifference(), 0) // no realtime
        XCTAssertEqual(events[2].getEstimatedTime(), events[2].getScheduledTime())
    }

    func testDepartureTimePrefersEstimate() throws {
        let events = try departures()
        XCTAssertEqual(events[0].departureTime, events[0].departureTimeEstimated)
        XCTAssertEqual(events[2].departureTime, events[2].departureTimePlanned)
    }

    func testGetIn() throws {
        let event = try departures()[0] // departs 08:42:18
        let now = try Date("2026-10-01T08:30:59Z", strategy: .iso8601)
        XCTAssertEqual(event.getIn(date: now), 12) // minutes compared, seconds ignored
        let later = try Date("2026-10-01T08:50:00Z", strategy: .iso8601)
        XCTAssertEqual(event.getIn(date: later), 0)
        XCTAssertEqual(event.getIn(date: later, realInTime: true), -8)
    }

    func testIDStableAcrossRealtimeUpdates() throws {
        let event = try departures()[0]
        var updated = event
        updated.departureTimeEstimated = event.departureTimeEstimated?.addingTimeInterval(120)
        XCTAssertEqual(event.id, updated.id)
        XCTAssertNotEqual(event, updated)
    }

    func testRefreshKeepsScrolledPages() throws {
        let events = try departures() // planned 08:37, 08:38, 08:43
        var refreshed = events[1]
        refreshed.departureTimeEstimated = refreshed.departureTimeEstimated?.addingTimeInterval(60)

        // first page now only covers up to 08:38; 08:37 has departed
        let merged = mergeFirstPage([refreshed], into: events)

        XCTAssertEqual(merged.map(\.id), [events[1].id, events[2].id])
        XCTAssertEqual(merged[0].departureTimeEstimated, refreshed.departureTimeEstimated) // fresh data wins
    }

    // MARK: EFA stop sequence

    func testStopSequence() throws {
        let stops = try JSONDecoder.efa.decode(StopSequenceContainer.self, from: fixture("efa_stop_sequence.json")).leg.stopSequence ?? []
        XCTAssertEqual(stops.count, 3)
        XCTAssertEqual(stops[0].getTimeDifference(), 5)
        // last stop only has arrival times
        XCTAssertNil(stops[2].departureTimePlanned)
        XCTAssertEqual(stops[2].timetabledTime, stops[2].arrivalTimePlanned)
        XCTAssertEqual(stops[2].getTimeDifference(), 5) // 09:02 -> 09:07:06
    }

    // MARK: WebAPI trip

    func testWebAPIDateParser() {
        let expected = Date(timeIntervalSince1970: 1681824120)
        XCTAssertEqual(DateParser.extractTimestamp(time: "/Date(1681824120000-0000)/"), expected)
        XCTAssertEqual(DateParser.extractTimestamp(time: "/Date(1681824120000+0200)/"), expected)
        XCTAssertNil(DateParser.extractTimestamp(time: "2026-10-01T08:37:00Z"))
    }

    func testDecodesTrip() {
        let route = tripTmp.Routes[0] // Data/trip.json, decoded with JSONDecoder.vvo
        XCTAssertEqual(route.getStartTime(), Date(timeIntervalSince1970: 1681916580))
        XCTAssertEqual(route.getEndTime(), Date(timeIntervalSince1970: 1681916640))
        XCTAssertEqual(route.getTimeDifference(), 1)
    }

    // MARK: Helpers

    func testMinutesBetweenIgnoresSeconds() {
        let start = Date(timeIntervalSince1970: 1681824059) // hh:mm:59
        XCTAssertEqual(minutesBetween(start, start.addingTimeInterval(2)), 1)
        XCTAssertEqual(minutesBetween(start, start.addingTimeInterval(-59)), 0)
    }
}
