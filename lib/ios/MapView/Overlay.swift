import Foundation
import MAMapKit
import UIKit

protocol Overlay: UIView {
  func getOverlay() -> MABaseOverlay?
  func getRenderer() -> MAOverlayRenderer
}

typealias AMapEventCallback = @convention(block) ([String: Any]?) -> Void
