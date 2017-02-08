import Foundation

extension PlanDay {
  override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
    var keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)

    switch key {
    case #keyPath(name):
      keyPaths.insert(#keyPath(order))
    case #keyPath(weekName):
      keyPaths.insert(#keyPath(week))
    default:
      break
    }

    return keyPaths
  }

  var name: String {
    return String(
      format: NSLocalizedString("Day %d", comment: "Day description format"),
      order
    )
  }

  var weekName: String {
    return String(
      format: NSLocalizedString("Week %d", comment: "Week description format"),
      week
    )
  }
}
