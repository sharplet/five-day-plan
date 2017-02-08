import UIKit

extension UIAlertController {
  static func makeAlert(for error: Error) -> UIAlertController {
    let alert = UIAlertController(
      title: NSLocalizedString("Something Went Wrong", comment: "Title for error message"),
      message: error.localizedDescription,
      preferredStyle: .alert
    )

    let ok = UIAlertAction(
      title: NSLocalizedString("OK", comment: "Error confirmation - OK"),
      style: .default,
      handler: nil
    )
    alert.addAction(ok)

    return alert
  }
}
