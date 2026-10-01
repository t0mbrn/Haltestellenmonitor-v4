//
//  LocationManager.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?
    @Published var llocation: CLLocation?

    private var completion: (() -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    func requestCurrentLocation() {
        locationManager.startUpdatingLocation()
    }

    func requestCurrentLocationComplete(completion: @escaping () -> Void) {
        self.completion = completion
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.requestCurrentLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        var newStops: [Stop] = []
        stops.forEach { stop in
            var newStop = stop
            newStop.distance = location.distance(from: CLLocation(latitude: stop.coordinates.latitude, longitude: stop.coordinates.longitude))
            newStops.append(newStop)
        }
        stops = newStops

        DispatchQueue.main.async {
            self.location = location.coordinate
        }
        self.llocation = location

        if completion != nil {
            completion!()
            completion = nil
        }

        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle any errors here...
        print("LocationManager Error: \(error)")
    }

    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.llocation {
            let geocoder = CLGeocoder()

            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                } else {
                 // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        } else {
            // No location was available.
            completionHandler(nil)
        }
    }
}
