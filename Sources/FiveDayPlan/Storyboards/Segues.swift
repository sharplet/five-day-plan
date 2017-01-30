import Perform

extension Segue {
  static var showDayDetail: Segue<PlanDayDetailViewController> {
    return .init(identifier: "Day Detail")
  }
}
