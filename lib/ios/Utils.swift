import CoreLocation
import Foundation
import MAMapKit
import UIKit

extension NSDictionary {
  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2DMake(self["latitude"] as! Double, self["longitude"] as! Double)
  }

  var point: CGPoint {
    CGPoint(x: self["x"] as! Double, y: self["y"] as! Double)
  }
}

extension CLLocationCoordinate2D {
  var json: [String: Any] {
    ["latitude": latitude, "longitude": longitude]
  }
}

extension MAUserLocation {
  var json: [String: Any] {
    // 拆开写，避免 Swift 对嵌套字典做类型推断超时
    let coords: [String: Any] = [
      "latitude": coordinate.latitude,
      "longitude": coordinate.longitude,
      "altitude": location?.altitude ?? 0,
      "heading": heading?.trueHeading ?? 0,
      "accuracy": location?.horizontalAccuracy ?? 0,
      "speed": location?.speed ?? 0,
    ]
    return [
      "coords": coords,
      "timestamp": Date().timeIntervalSince1970 * 1000,
    ]
  }
}

extension MACoordinateRegion {
  var json: [String: Any] {
    [
      "southwest": [
        "latitude": center.latitude - span.latitudeDelta / 2,
        "longitude": center.longitude - span.longitudeDelta / 2,
      ],
      "northeast": [
        "latitude": center.latitude + span.latitudeDelta / 2,
        "longitude": center.longitude + span.longitudeDelta / 2,
      ],
    ]
  }
}

extension MAMapStatus {
  var json: [String: Any] {
    [
      "target": centerCoordinate.json,
      "zoom": zoomLevel,
      "bearing": rotationDegree,
      "tilt": cameraDegree,
    ]
  }
}

extension MAMapView {
  var cameraEvent: [String: Any] {
    [
      "cameraPosition": getMapStatus().json,
      "latLngBounds": region.json,
    ]
  }
}

extension Double {
  var cgFloat: CGFloat {
    CGFloat(self)
  }
}

enum AMapImageLoader {
  static func load(_ source: NSDictionary?, completion: @escaping (UIImage) -> Void) {
    guard
      let uri = source?["uri"] as? String,
      let url = URL(string: uri)
    else { return }

    let finish: (Data?) -> Void = { data in
      guard let data, let image = UIImage(data: data) else { return }
      DispatchQueue.main.async { completion(image) }
    }

    if url.isFileURL {
      DispatchQueue.global(qos: .userInitiated).async {
        finish(try? Data(contentsOf: url))
      }
    } else {
      URLSession.shared.dataTask(with: url) { data, _, _ in finish(data) }.resume()
    }
  }
}
