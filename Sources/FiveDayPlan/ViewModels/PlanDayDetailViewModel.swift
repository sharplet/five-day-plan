struct PlanDayDetailViewModel {
  let title: String
  let chapters: [Scripture.Chapter]
  let provider: ScriptureProvider

  init(title: String, scriptures: ScriptureCollection, provider: ScriptureProvider = YouVersionScriptureProvider()) {
    self.title = title
    self.chapters = scriptures.chapters
    self.provider = provider
  }

  func openChapter(at index: Int, completionHandler: @escaping (Bool) -> Void) {
    provider.open(chapters[index], completionHandler: completionHandler)
  }
}
