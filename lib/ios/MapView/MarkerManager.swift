import CoreLocation
import Foundation
import MAMapKit
import UIKit

@objc(AMapNativeMarker)
class Marker: UIView {
  var view: MAAnnotationView?
  var annotation = MAPointAnnotation()
  var icon: UIImage?
  var iconView: UIView?
  var centerOffset: CGPoint?

  @objc var draggable = false { didSet { view?.isDraggable = draggable } }
  /// Consumed from View style `zIndex` via Fabric BaseViewProps (KVC), not a custom prop.
  @objc var zIndex = 0 { didSet { view?.zIndex = zIndex } }

  @objc dynamic var onPress: AMapEventCallback = { _ in }
  @objc dynamic var onDragStart: AMapEventCallback = { _ in }
  @objc dynamic var onDrag: AMapEventCallback = { _ in }
  @objc dynamic var onDragEnd: AMapEventCallback = { _ in }

  @objc func setIcon(_ icon: NSDictionary?) {
    let apply: (UIImage) -> Void = { image in
      self.icon = image
      self.view?.image = image
      self.updateCenterOffset()
    }
    AMapImageLoader.load(icon, completion: apply)
  }

  @objc func setLatLng(_ coordinate: CLLocationCoordinate2D) {
    annotation.coordinate = coordinate
  }

  @objc func setCenterOffset(_ centerOffset: CGPoint) {
    self.centerOffset = centerOffset
    view?.centerOffset = centerOffset
  }

  override func didAddSubview(_ subview: UIView) {
    super.didAddSubview(subview)
    subview.layer.opacity = 0
    iconView = subview
  }

  /**
   * subview 不能直接用作 marker 的 icon，因为在实现点聚合的时候发现，subview 一定概率无法正常 layout，会堆在右上角。
   * 于是索性把 subview 渲染成 image，原来用 subview 带来的 offset、点击问题也都不用处理了。
   * 正常情况下就把 subview 的 opacity 设成 0，需要渲染的时候才设成 1，渲染然后马上设回 0。
   */
  func update() {
    if centerOffset == nil, view != nil {
      iconView?.layer.opacity = 1
      let renderer = UIGraphicsImageRenderer(bounds: iconView!.bounds)
      view?.image = renderer.image { context in layer.render(in: context.cgContext) }
      iconView?.layer.opacity = 0
      updateCenterOffset()
    }
  }

  func updateCenterOffset() {
    if centerOffset == nil, view != nil {
      let size: CGSize = (view?.image.size)!
      view?.centerOffset = CGPoint(x: 0, y: -size.height / 2)
    }
  }

  func getView() -> MAAnnotationView {
    if view == nil {
      view = MAAnnotationView(annotation: annotation, reuseIdentifier: nil)
      if icon == nil, iconView == nil {
        view?.image = MAPinAnnotationView(annotation: annotation, reuseIdentifier: nil).image
      }
      view?.isDraggable = draggable
      view?.zIndex = zIndex
      if centerOffset != nil {
        view?.centerOffset = centerOffset!
      }
      if icon != nil {
        view?.image = icon
        updateCenterOffset()
      }
    }
    return view!
  }
}
