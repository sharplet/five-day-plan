import CoreData

final class Store {
  static let shared = Store()

  private let container: PersistentContainer

  init() {
    container = PersistentContainer(name: "FiveDayPlan")
    container.unsafeViewContext.automaticallyMergesChangesFromParent = true
  }

  func initialisePlan(_ plan: @autoclosure @escaping () -> PlanTemplate, completionHandler: @escaping (Error?) -> Void) {
    withViewContext(failingWith: completionHandler) { context in
      let currentPlanRequest: NSFetchRequest<Plan> = Plan.fetchRequest()
      currentPlanRequest.fetchLimit = 1

      let currentPlan = try context.fetch(currentPlanRequest).first

      guard currentPlan == nil else {
        completionHandler(nil)
        return
      }

      self.performBackgroundTask(qos: .userInitiated, failingWith: completionHandler) { context in
        _ = Plan(fromTemplate: plan(), insertInto: context)

        try context.save()

        DispatchQueue.main.async {
          completionHandler(nil)
        }
      }
    }
  }

  func planOutlineController() -> NSFetchedResultsController<PlanDay> {
    let request: NSFetchRequest<PlanDay> = PlanDay.fetchRequest()
    request.sortDescriptors = [
      NSSortDescriptor(key: #keyPath(PlanDay.week), ascending: true),
      NSSortDescriptor(key: #keyPath(PlanDay.order), ascending: true),
    ]

    return NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: container.unsafeViewContext,
      sectionNameKeyPath: #keyPath(PlanDay.weekName),
      cacheName: nil
    )
  }

  private func performBackgroundTask(qos: DispatchQoS.QoSClass, failingWith completionHandler: @escaping (Error?) -> Void, block: @escaping (NSManagedObjectContext) throws -> Void) {
    container.performBackgroundTask(qos: qos) { context, error in
      func complete(with error: Error? = nil) {
        DispatchQueue.main.async {
          completionHandler(error)
        }
      }

      guard let context = context else { complete(); return }
      do {
        try block(context)
      } catch {
        complete(with: error)
      }
    }
  }

  private func withViewContext(failingWith completionHandler: @escaping (Error?) -> Void, block: @escaping (NSManagedObjectContext) throws -> Void) {
    container.withViewContext { context, error in
      func complete(with error: Error? = nil) {
        DispatchQueue.main.async {
          completionHandler(error)
        }
      }

      guard let context = context else { complete(); return }
      do {
        try block(context)
      } catch {
        complete(with: error)
      }
    }
  }
}
