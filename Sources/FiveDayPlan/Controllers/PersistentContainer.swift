import CoreData

private let isInitializing = 0
private let isInitialized = 1

final class PersistentContainer {
  private let container: NSPersistentContainer
  private let lock = NSConditionLock(condition: isInitializing)

  private var loadError: Error?

  init(name: String) {
    container = NSPersistentContainer(name: name)

    let initQueue = DispatchQueue(label: "Store.init")

    initQueue.sync {
      lock.lock()

      container.loadPersistentStores { [lock, weak self] description, error in
        dispatchPrecondition(condition: .onQueue(initQueue))

        if let error = error {
          self?.loadError = error
        }

        lock.unlock(withCondition: isInitialized)
      }
    }
  }

  func performBackgroundTask(qos: DispatchQoS.QoSClass, block: @escaping (NSManagedObjectContext?, Error?) -> Void) {
    DispatchQueue.global(qos: qos).async {
      do {
        try self.waitForInitialization()
        self.container.performBackgroundTask { context in
          block(context, nil)
        }
      } catch {
        block(nil, error)
      }
    }
  }

  func withViewContext(block: @escaping (NSManagedObjectContext?, Error?) -> Void) {
    DispatchQueue.main.async {
      do {
        try self.waitForInitialization(on: RunLoop.current)
        block(self.container.viewContext, nil)
      } catch {
        block(nil, error)
      }
    }
  }

  private func waitForInitialization() throws {
    lock.lock(whenCondition: isInitialized)
    defer { lock.unlock() }
    if let loadError = loadError { throw loadError }
  }

  private func waitForInitialization(on runloop: RunLoop) throws {
    while !(try self.checkInitialized()) {
      runloop.run(mode: .defaultRunLoopMode, before: Date())
    }
  }

  private func checkInitialized() throws -> Bool {
    guard lock.tryLock(whenCondition: isInitialized) else {
      return false
    }

    defer { lock.unlock() }

    if let loadError = loadError {
      throw loadError
    }

    return true
  }
}
