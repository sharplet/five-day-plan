import CircleProgressView
import UIKit

final class DaySummaryCell: UITableViewCell {
  @IBOutlet private(set) var titleLabel: UILabel?
  @IBOutlet private(set) var subtitleLabel: UILabel?
  @IBOutlet private(set) var progressView: CircleProgressView?

  override var textLabel: UILabel? {
    return titleLabel
  }

  override var detailTextLabel: UILabel? {
    return subtitleLabel
  }
}
