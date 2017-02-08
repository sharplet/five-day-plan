extension Scripture.Chapter {
  init(_ chapter: PlanChapter) {
    self.init(
      book: Scripture.Book(rawValue: chapter.book!)!,
      chapter: Int(chapter.number)
    )!
  }
}
