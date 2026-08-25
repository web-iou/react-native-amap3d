import CoreLocation
import Foundation
import MAMapKit
import UIKit

@objc(AMapNativePolygon)
class Polygon: UIView, Overlay {
  var overlay = MAPolygon()
  var renderer: MAPolygonRenderer?

  @objc var strokeWidth = 1.0 { didSet { renderer?.lineWidth = strokeWidth } }
  @objc var strokeColor = UIColor.black { didSet { renderer?.strokeColor = strokeColor } }
  @objc var fillColor = UIColor.white { didSet { renderer?.fillColor = fillColor } }

  @objc func setPoints(_ points: NSArray) {
    var coordinates = points.map { it -> CLLocationCoordinate2D in (it as! NSDictionary).coordinate }
    overlay.setPolygonWithCoordinates(&coordinates, count: points.count)
  }

  /// Consumed from View style `zIndex` via Fabric BaseViewProps (KVC).
  @objc var zIndex: Int = 0

  func getOverlay() -> MABaseOverlay? { overlay }
  func getRenderer() -> MAOverlayRenderer {
    if renderer == nil {
      renderer = MAPolygonRenderer(polygon: overlay)
      renderer?.fillColor = fillColor
      renderer?.strokeColor = strokeColor
      renderer?.lineWidth = strokeWidth
    }
    return renderer!
  }
}
