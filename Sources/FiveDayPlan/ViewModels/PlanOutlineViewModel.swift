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

  func indexPathForNextUnread() -> IndexPath? {
    let request = PlanDay.fetchOutline()
    request.fetchLimit = 1
    request.includesPropertyValues = false
    request.predicate = NSPredicate(format: "ANY chapters.@sum.isRead < chapters.@count")

    guard let result = (try? fetchController.managedObjectContext.fetch(request))?.first,
      let indexPath = fetchController.indexPath(forObject: result)
      else { return nil }

    return indexPath
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
    return PlanDayDetailViewModel(day: self[indexPath], store: store)
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
