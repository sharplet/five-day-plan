import CoreData

final class Store {
  static let shared = Store()

  private let container: PersistentContainer

  init() {
    container = PersistentContainer(name: "FiveDayPlan")
  }

  func initialisePlan(completionHandler: @escaping (Error?) -> Void) {
    withViewContext(failingWith: completionHandler) { _ in
      completionHandler(nil)
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
