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
      let currentPlan = try Plan.first(in: context)

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
    request.sortDescriptors = [.byPlanWeek, .byPlanDay]

    return NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: container.unsafeViewContext,
      sectionNameKeyPath: #keyPath(PlanDay.weekName),
      cacheName: nil
    )
  }

  func planDayController(for day: PlanDay) -> NSFetchedResultsController<PlanChapter> {
    let request: NSFetchRequest<PlanChapter> = PlanChapter.fetchRequest()
    request.predicate = NSPredicate(format: "day == %@", day)
    request.sortDescriptors = [.byPlanDayChapter]

    return NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: container.unsafeViewContext,
      sectionNameKeyPath: #keyPath(PlanChapter.day.name),
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
