import CoreLocation
import Foundation
import MAMapKit
import UIKit

@objc(AMapNativeMapView)
class MapView: MAMapView, MAMapViewDelegate {
  var initialized = false
  var overlayMap: [MABaseOverlay: Overlay] = [:]
  var markerMap: [MAPointAnnotation: Marker] = [:]

  @objc dynamic var onLoad: AMapEventCallback = { _ in }
  @objc dynamic var onCameraMove: AMapEventCallback = { _ in }
  @objc dynamic var onCameraIdle: AMapEventCallback = { _ in }
  @objc dynamic var onPress: AMapEventCallback = { _ in }
  @objc dynamic var onPressPoi: AMapEventCallback = { _ in }
  @objc dynamic var onLongPress: AMapEventCallback = { _ in }
  @objc dynamic var onLocation: AMapEventCallback = { _ in }
  @objc dynamic var onCallback: AMapEventCallback = { _ in }

  override init(frame: CGRect) {
    super.init(frame: frame)
    delegate = self
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    delegate = self
  }

  @objc func setInitialCameraPosition(_ json: NSDictionary) {
    if !initialized {
      initialized = true
      moveCamera(position: json)
    }
  }

  /// Fabric 组件回收复用时重置，避免第二次进页仍用旧相机 / 旧定位态
  @objc func resetForRecycle() {
    initialized = false
    showsUserLocation = false
    removeAnnotations(annotations)
    removeOverlays(overlays)
    overlayMap.removeAll()
    markerMap.removeAll()
  }

  func moveCamera(position: NSDictionary, duration: Int = 0) {
    let status = MAMapStatus()
    status.zoomLevel = (position["zoom"] as? Double)?.cgFloat ?? zoomLevel
    status.cameraDegree = (position["tilt"] as? Double)?.cgFloat ?? cameraDegree
    status.rotationDegree = (position["bearing"] as? Double)?.cgFloat ?? rotationDegree
    status.centerCoordinate = (position["target"] as? NSDictionary)?.coordinate ?? centerCoordinate
    setMapStatus(status, animated: true, duration: Double(duration) / 1000)
  }

  /// Fabric `AMapViewComponentView` 通过 objc_msgSend 调用
  @objc(moveCameraWithPosition:duration:)
  func moveCameraWithPosition(_ position: NSDictionary, duration: Int) {
    moveCamera(position: position, duration: duration)
  }

  func call(id: Double, name: String, args: NSDictionary) {
    switch name {
    case "getLatLng":
      callback(id: id, data: convert(args.point, toCoordinateFrom: self).json)
    default:
      break
    }
  }

  @objc(callWithId:name:args:)
  func callWithId(_ id: Double, name: String, args: NSDictionary) {
    call(id: id, name: name, args: args)
  }

  func callback(id: Double, data: [String: Any]) {
    onCallback(["id": id, "data": data])
  }

  @objc func mountFabricSubview(_ subview: UIView) {
    if let multiPoint = subview as? MultiPoint {
      multiPoint.attach(to: self)
    } else if let overlayView = subview as? Overlay, let overlay = overlayView.getOverlay() {
      overlayMap[overlay] = overlayView
      add(overlay)
    }
    if let annotation = (subview as? Marker)?.annotation {
      markerMap[annotation] = subview as? Marker
      addAnnotation(annotation)
    }
  }

  @objc func unmountFabricSubview(_ subview: UIView) {
    if let multiPoint = subview as? MultiPoint {
      multiPoint.detach(from: self)
    } else if let overlayView = subview as? Overlay, let overlay = overlayView.getOverlay() {
      overlayMap.removeValue(forKey: overlay)
      remove(overlay)
    }
    if let annotation = (subview as? Marker)?.annotation {
      markerMap.removeValue(forKey: annotation)
      removeAnnotation(annotation)
    }
  }

  func mapView(_: MAMapView, rendererFor overlay: MAOverlay) -> MAOverlayRenderer? {
    if let key = overlay as? MABaseOverlay {
      return overlayMap[key]?.getRenderer()
    }
    return nil
  }

  func mapView(_: MAMapView!, viewFor annotation: MAAnnotation) -> MAAnnotationView? {
    if let key = annotation as? MAPointAnnotation {
      return markerMap[key]?.getView()
    }
    return nil
  }

  func mapView(_: MAMapView!, annotationView view: MAAnnotationView!, didChange newState: MAAnnotationViewDragState, fromOldState _: MAAnnotationViewDragState) {
    if let key = view.annotation as? MAPointAnnotation {
      let market = markerMap[key]!
      if newState == MAAnnotationViewDragState.starting {
        market.onDragStart(nil)
      }
      if newState == MAAnnotationViewDragState.dragging {
        market.onDrag(nil)
      }
      if newState == MAAnnotationViewDragState.ending {
        market.onDragEnd(view.annotation.coordinate.json)
      }
    }
  }

  func mapView(_: MAMapView!, didAnnotationViewTapped view: MAAnnotationView!) {
    if let key = view.annotation as? MAPointAnnotation {
      markerMap[key]?.onPress(nil)
    }
  }

  func mapInitComplete(_: MAMapView!) {
    onLoad(nil)
  }

  func mapView(_: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
    onPress(coordinate.json)
  }

  func mapView(_: MAMapView!, didTouchPois pois: [Any]!) {
    let poi = pois[0] as! MATouchPoi
    onPressPoi(["name": poi.name!, "id": poi.uid!, "position": poi.coordinate.json])
  }

  func mapView(_: MAMapView!, didLongPressedAt coordinate: CLLocationCoordinate2D) {
    onLongPress(coordinate.json)
  }

  func mapViewRegionChanged(_: MAMapView!) {
    onCameraMove(cameraEvent)
  }

  func mapView(_: MAMapView!, regionDidChangeAnimated _: Bool) {
    onCameraIdle(cameraEvent)
  }

  func mapView(_: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation _: Bool) {
    onLocation(userLocation.json)
  }

  /// 定位权限未定时 AMap 会回调；必须主动 request，否则开启 showsUserLocation 可能异常
  func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
    if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
      locationManager.requestWhenInUseAuthorization()
    }
  }

  func mapView(_: MAMapView!, didFailToLocateUserWithError error: Error!) {
    #if DEBUG
      print("[AMapNativeMapView] locate failed: \(String(describing: error))")
    #endif
  }
}
