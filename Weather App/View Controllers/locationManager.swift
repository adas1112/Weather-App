import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var onLocationUpdate: ((String, String) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocationPermission()
    }

    private func requestLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            let status = locationManager.authorizationStatus
            handleAuthorizationStatus(status)
        } else {
            print("Location services are disabled. Please enable them in Settings.")
        }
    }

    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization() // Request permission
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation() // Start only when authorized
        case .restricted, .denied:
            print("Location permission denied. Please enable it in settings.")
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationStatus(manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            onLocationUpdate?(latitude, longitude)
            locationManager.stopUpdatingLocation() // Stop after fetching location
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
