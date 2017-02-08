import CoreData
import Foundation

final class PlanOutlineViewModel {
  let fetchController: NSFetchedResultsController<PlanDay>
  let store: Store
  private let getTemplate: () -> PlanTemplate
  private var state = InitialisationState.uninitialised

  private(set) var sections: [PlanOutlineSection]

  init(plan: @autoclosure @escaping () -> PlanTemplate, store: Store) {
    self.fetchController = store.planOutlineController()
    self.getTemplate = plan
    self.sections = plan().weeks.map(PlanOutlineSection.init)
    self.store = store
  }

  func performFetch() throws {
    try fetchController.performFetch()
  }

  func initialise(completion: @escaping (Error?) -> Void) {
    dispatchPrecondition(condition: .onQueue(.main))

    guard state.isUninitialised else { return }

    state = .loading

    store.initialisePlan(self.getTemplate()) { error in
      dispatchPrecondition(condition: .onQueue(.main))

      if error == nil {
        self.state = .initialised
      } else {
        self.state = .uninitialised
      }

      completion(error)
    }
  }

  func numberOfRows(inSection section: Int) -> Int {
    return sections[section].rows.count
  }

  subscript(indexPath: IndexPath) -> PlanOutlineRow {
    return sections[indexPath.section].rows[indexPath.row]
  }
}

private extension PlanOutlineViewModel {
  enum InitialisationState {
    case uninitialised
    case loading
    case initialised

    var isUninitialised: Bool {
      switch self {
      case .uninitialised:
        return true
      case .loading, .initialised:
        return false
      }
    }
  }
}

struct PlanOutlineSection {
  let title: String

  private(set) var rows: [PlanOutlineRow]

  init(week: PlanTemplate.Week) {
    title = week.title
    rows = week.days.enumerated().map { offset, scriptures in
      PlanOutlineRow(title: "Day \(offset + 1)", scriptures: scriptures)
    }
  }
}

struct PlanOutlineRow {
  let title: String
  let subtitle: String?

  private let scriptures: ScriptureCollection

  init(title: String, scriptures: ScriptureCollection) {
    self.title = title
    self.subtitle = scriptures.formattedSummary
    self.scriptures = scriptures
  }

  var dayDetails: PlanDayDetailViewModel {
    return PlanDayDetailViewModel(title: title, scriptures: scriptures)
  }
}

private extension ScriptureCollection {
  var formattedSummary: String {
    return summary
      .replacingOccurrences(of: "-", with: "–")
  }
}
