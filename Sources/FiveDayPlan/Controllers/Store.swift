import CoreData

final class Store {
  static let shared = Store()

  private let container: PersistentContainer

  init() {
    container = PersistentContainer(name: "FiveDayPlan")
  }

  func initialisePlan(completionHandler: @escaping (Error?) -> Void) {
    withViewContext(failingWith: completionHandler) { context in
      let currentPlanRequest: NSFetchRequest<Plan> = Plan.fetchRequest()
      currentPlanRequest.fetchLimit = 1

      let currentPlan = try context.fetch(currentPlanRequest).first

      guard currentPlan == nil else {
        completionHandler(nil)
        return
      }

      self.performBackgroundTask(qos: .userInitiated, failingWith: completionHandler) { context in
        let template: PlanTemplate = .year2017

        let plan = NSEntityDescription.insertNewObject(forEntityName: Plan.entity().name!, into: context) as! Plan

        for (weekOffset, week) in template.weeks.enumerated() {
          for (dayOffset, scriptures) in week.days.enumerated() {
            let day = NSEntityDescription.insertNewObject(forEntityName: PlanDay.entity().name!, into: context) as! PlanDay
            day.summary = scriptures.summary
            day.order = Int16(dayOffset + 1)
            day.week = Int16(weekOffset + 1)
            plan.addToDays(day)

            for scripture in scriptures.chapters {
              let chapter = NSEntityDescription.insertNewObject(forEntityName: PlanChapter.entity().name!, into: context) as! PlanChapter
              chapter.name = scripture.description
              day.addToChapters(chapter)
            }
          }
        }

        try context.save()

        DispatchQueue.main.async {
          completionHandler(nil)
        }
      }
    }
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
