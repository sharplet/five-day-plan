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
#if (arch(i386) || arch(x86_64)) && os(iOS)
      let success = true
#endif
      if success {
        self.markAsRead(at: indexPath, completionHandler: completionHandler)
      } else {
        completionHandler(nil)
      }
    }
  }

  func markAsUnread(at indexPath: IndexPath, completionHandler: @escaping (Error?) -> Void) {
    updateChapter(at: indexPath, completionHandler: completionHandler) { chapter, save in
      guard chapter.isRead else { save = false; return }
      chapter.isRead = false
    }
  }

  func markAsRead(at indexPath: IndexPath, completionHandler: @escaping (Error?) -> Void) {
    updateChapter(at: indexPath, completionHandler: completionHandler) { chapter, save in
      guard !chapter.isRead else { save = false; return }
      chapter.isRead = true
    }
  }

  private func updateChapter(at indexPath: IndexPath, completionHandler: @escaping (Error?) -> Void, modify: @escaping (_ chapter: PlanChapter, _ save: inout Bool) -> Void) {
    let objectID = self[indexPath].objectID

    store.performBackgroundTask(failingWith: completionHandler) { context in
      let chapter = PlanChapter.fetch(by: objectID, in: context)
      var save = true
      modify(chapter, &save)
      if save {
        try context.save()
      }
    }
  }
}
