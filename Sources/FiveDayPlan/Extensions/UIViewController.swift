import UIKit

extension UIViewController {
  func show(_ error: Error) {
    let alert = UIAlertController.makeAlert(for: error)
#if DEBUG
    debugPrint(error)
#endif
    self.showDetailViewController(alert, sender: self)
  }
}
