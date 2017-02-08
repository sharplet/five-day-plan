import CoreData

struct PlanDayDetailViewModel {
  let title: String
  let provider: ScriptureProvider
  let fetchController: NSFetchedResultsController<PlanChapter>
  let store: Store

  init(day: PlanDay, provider: ScriptureProvider = YouVersionScriptureProvider(), store: Store) {
    self.title = day.name
    self.provider = provider
    self.fetchController = store.planDayController(for: day)
    self.store = store
  }

  func performFetch() throws {
    try fetchController.performFetch()
  }

  var numberOfSections: Int {
    return fetchController.sections?.count ?? 0
  }

  func numberOfChapters(in section: Int) -> Int {
    return fetchController.sections?[section].numberOfObjects ?? 0
  }

  subscript(indexPath: IndexPath) -> PlanChapter {
    return fetchController.object(at: indexPath)
  }

  func openChapter(at indexPath: IndexPath, completionHandler: @escaping (Error?) -> Void) {
    let chapter = Scripture.Chapter(self[indexPath])
    provider.open(chapter) { success in
      if success {
        self.markAsRead(at: indexPath, completionHandler: completionHandler)
      } else {
        completionHandler(nil)
      }
    }
  }

  private func markAsRead(at indexPath: IndexPath, completionHandler: @escaping (Error?) -> Void) {
    let objectID: NSManagedObjectID

    do {
      let chapter = self[indexPath]
      guard !chapter.isRead else { completionHandler(nil); return }
      objectID = self[indexPath].objectID
    }

    store.performBackgroundTask(failingWith: completionHandler) { context in
      let chapter = PlanChapter.fetch(by: objectID, in: context)
      chapter.isRead = true
      try context.save()
    }
  }
}
