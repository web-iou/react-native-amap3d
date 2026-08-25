import Foundation
import MAMapKit
import UIKit

@objc(AMapNativeMultiPoint)
class MultiPoint: UIView, Overlay, MAMultiPointOverlayRendererDelegate {
  weak var mapView: MapView?
  var overlay: MAMultiPointOverlay?
  var renderer: MAMultiPointOverlayRenderer?
  var icon: UIImage?

  @objc dynamic var onPress: AMapEventCallback = { _ in }

  @objc func setIcon(_ source: NSDictionary?) {
    let apply: (UIImage) -> Void = { image in
      self.icon = image
      self.renderer?.icon = image
    }
    AMapImageLoader.load(source, completion: apply)
  }

  @objc func setItems(_ items: NSArray) {
    let previous = overlay
    overlay = MAMultiPointOverlay(multiPointItems: items.map { it -> MAMultiPointItem in
      let item = MAMultiPointItem()
      item.coordinate = (it as! NSDictionary).coordinate
      return item
    })
    renderer = nil
    replaceOverlay(previous: previous)
  }

  func getOverlay() -> MABaseOverlay? { overlay }

  func getRenderer() -> MAOverlayRenderer {
    if renderer == nil {
      renderer = MAMultiPointOverlayRenderer(multiPointOverlay: overlay)
      renderer?.icon = icon
      renderer?.delegate = self
    }
    return renderer!
  }

  func attach(to map: MapView) {
    mapView = map
    replaceOverlay(previous: nil)
  }

  func detach(from map: MapView) {
    if let overlay = overlay {
      map.overlayMap.removeValue(forKey: overlay)
      map.remove(overlay)
    }
    mapView = nil
  }

  private func replaceOverlay(previous: MAMultiPointOverlay?) {
    guard let map = mapView else { return }
    if let previous = previous {
      map.overlayMap.removeValue(forKey: previous)
      map.remove(previous)
    }
    guard let overlay = overlay else { return }
    map.overlayMap[overlay] = self
    map.add(overlay)
  }

  func multiPointOverlayRenderer(_: MAMultiPointOverlayRenderer!, didItemTapped item: MAMultiPointItem!) {
    guard let overlay = overlay, let index = overlay.items.firstIndex(of: item) else { return }
    onPress(["index": index])
  }
}
