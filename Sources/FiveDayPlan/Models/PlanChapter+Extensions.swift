import CoreData

extension PlanChapter {
  convenience init(scripture: Scripture.Chapter, order: Int, insertInto context: NSManagedObjectContext?) {
    self.init(entity: type(of: self).entity(), insertInto: context)
    self.book = scripture.book.rawValue
    self.name = scripture.description
    self.order = Int16(order)
    if let number = scripture.chapter {
      self.number = Int16(number)
    }
  }
}

extension Scripture.Chapter {
  init(_ chapter: PlanChapter) {
    self.init(
      book: Scripture.Book(rawValue: chapter.book!)!,
      chapter: Int(chapter.number)
    )!
  }
}

extension NSSortDescriptor {
  static var byPlanDayChapter: NSSortDescriptor {
    return NSSortDescriptor(key: #keyPath(PlanChapter.order), ascending: true)
  }
}
