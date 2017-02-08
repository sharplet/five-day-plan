struct PlanDayDetailViewModel {
  let title: String
  let provider: ScriptureProvider
  private let chapters: [PlanChapter]

  init(day: PlanDay, provider: ScriptureProvider = YouVersionScriptureProvider()) {
    self.title = day.summary!
    self.provider = provider
    self.chapters = day.chapters!.array as! [PlanChapter]
  }

  var numberOfChapters: Int {
    return chapters.count
  }

  subscript(index: Int) -> Scripture.Chapter {
    return Scripture.Chapter(chapters[index])
  }

  func openChapter(at index: Int, completionHandler: @escaping (Bool) -> Void) {
    provider.open(self[index], completionHandler: completionHandler)
  }
}
