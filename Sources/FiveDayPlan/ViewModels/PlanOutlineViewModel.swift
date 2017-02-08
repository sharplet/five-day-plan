import CoreData
import Foundation

final class PlanOutlineViewModel {
  let fetchController: NSFetchedResultsController<PlanDay>
  let store: Store
  private let getTemplate: () -> PlanTemplate
  private var state = InitialisationState.uninitialised

  init(plan: @autoclosure @escaping () -> PlanTemplate, store: Store) {
    self.fetchController = store.planOutlineController()
    self.getTemplate = plan
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

  var numberOfSections: Int {
    return fetchController.sections?.count ?? 0
  }

  func numberOfRows(inSection section: Int) -> Int {
    return fetchController.sections?[section].numberOfObjects ?? 0
  }

  func titleForHeader(inSection section: Int) -> String? {
    return fetchController.sections?[section].name
  }

  subscript(indexPath: IndexPath) -> PlanDay {
    return fetchController.object(at: indexPath)
  }

  func dayDetails(at indexPath: IndexPath) -> PlanDayDetailViewModel {
    return PlanDayDetailViewModel(day: self[indexPath])
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
