import CoreData

extension PlanDay {
  private static var context: UInt8 = 0

  override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
    var keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)

    switch key {
    case #keyPath(name):
      keyPaths.insert(#keyPath(order))
    case #keyPath(weekName):
      keyPaths.insert(#keyPath(week))
    default:
      break
    }

    return keyPaths
  }

  convenience init(scriptures: ScriptureCollection, order: Int, week: Int, insertInto context: NSManagedObjectContext?) {
    self.init(entity: type(of: self).entity(), insertInto: context)

    self.summary = scriptures.summary
    self.order = Int16(order)
    self.week = Int16(week)

    for (offset, scripture) in scriptures.chapters.enumerated() {
      let chapter = PlanChapter(scripture: scripture, order: offset + 1, insertInto: context)
      addToChapters(chapter)
    }
  }

  public override func awakeFromFetch() {
    super.awakeFromFetch()
    addObservers()
  }

  public override func awakeFromInsert() {
    super.awakeFromInsert()
    addObservers()
  }

  public override func willTurnIntoFault() {
    super.willTurnIntoFault()
    removeObservers()
  }

  private func addObservers() {
    chapters?.forEach { chapter in
      (chapter as AnyObject).addObserver(self, forKeyPath: #keyPath(PlanChapter.isRead), options: [.initial, .new], context: &PlanDay.context)
    }
  }

  private func removeObservers() {
    chapters?.forEach { chapter in
      (chapter as AnyObject).removeObserver(self, forKeyPath: #keyPath(PlanChapter.isRead), context: &PlanDay.context)
    }
  }

  public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard context == &PlanDay.context,
      let chapter = object,
      chapters?.contains(chapter) == true,
      keyPath == #keyPath(PlanChapter.isRead)
      else {
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        return
      }

    chaptersRead = value(forKeyPath: "chapters.@sum.isRead") as! Int16
  }

  var chapterCount: Int {
    return chapters!.count
  }

  var formattedSummary: String {
    return summary!
      .replacingOccurrences(of: "-", with: "–")
  }

  var isComplete: Bool {
    return percentageRead == 1
  }

  var isInProgress: Bool {
    let percentage = percentageRead
    return 0 < percentage && percentage < 1
  }

  var name: String {
    return String(
      format: NSLocalizedString("Day %d", comment: "Day description format"),
      order
    )
  }

  var percentageRead: Double {
    return Double(chaptersRead) / Double(chapterCount)
  }

  var weekName: String {
    return String(
      format: NSLocalizedString("Week %d", comment: "Week description format"),
      week
    )
  }
}

extension NSSortDescriptor {
  static var byPlanWeek: NSSortDescriptor {
    return NSSortDescriptor(key: #keyPath(PlanDay.week), ascending: true)
  }

  static var byPlanDay: NSSortDescriptor {
    return NSSortDescriptor(key: #keyPath(PlanDay.order), ascending: true)
  }
}
