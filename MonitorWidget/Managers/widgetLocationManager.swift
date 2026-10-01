//
//  widgetLocationManager.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 03.11.23
//  Credit to https://github.com/AKORA-Studios for helping with the LocationManager
//

import Foundation
import CoreLocation

class WidgetLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()

    private var continuation: CheckedContinuation<CLLocation?, Never>?

    override init() {
        super.init()
        self.locationManager.delegate = self
        DispatchQueue.main.async {
            if self.locationManager.authorizationStatus == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    /// Returns nil when location is unavailable or not authorized.
    @MainActor
    func fetchLocation() async -> CLLocation? {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            break
        default:
            return nil
        }
        continuation?.resume(returning: nil)
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self.continuation?.resume(returning: locations.first)
            self.continuation = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("MonitorWidgetLocationManagerError ", error)
        DispatchQueue.main.async {
            self.continuation?.resume(returning: nil)
            self.continuation = nil
        }
    }
}
