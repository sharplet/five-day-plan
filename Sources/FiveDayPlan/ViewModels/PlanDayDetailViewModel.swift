import CoreData

struct PlanDayDetailViewModel {
  let title: String
  let provider: ScriptureProvider
  let fetchController: NSFetchedResultsController<PlanChapter>

  init(day: PlanDay, provider: ScriptureProvider = YouVersionScriptureProvider(), store: Store) {
    self.title = day.name
    self.provider = provider
    self.fetchController = store.planDayController(for: day)
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

  subscript(indexPath: IndexPath) -> Scripture.Chapter {
    let chapter = fetchController.object(at: indexPath)
    return Scripture.Chapter(chapter)
  }

  func openChapter(at indexPath: IndexPath, completionHandler: @escaping (Bool) -> Void) {
    provider.open(self[indexPath], completionHandler: completionHandler)
  }
}
