struct PlanDayDetailViewModel {
  let title: String
  let chapters: [Scripture.Chapter]

  init(title: String, scriptures: ScriptureCollection) {
    self.title = title
    self.chapters = scriptures.chapters
  }
}
