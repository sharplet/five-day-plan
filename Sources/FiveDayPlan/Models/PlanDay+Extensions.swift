import CoreData

extension PlanDay {
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
    updateChaptersRead()
    addObservers()
  }

  public override func awakeFromInsert() {
    super.awakeFromInsert()
    updateChaptersRead()
    addObservers()
  }

  private func addObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(objectsDidChange(_:)),
      name: .NSManagedObjectContextObjectsDidChange,
      object: managedObjectContext!
    )
  }

  @objc private func objectsDidChange(_ notification: Notification) {
    guard let refreshed = notification.userInfo![NSRefreshedObjectsKey] as! Set<AnyHashable>?,
      let chapters = chapters as! Set<AnyHashable>?,
      !chapters.intersection(refreshed).isEmpty
      else { return }

    updateChaptersRead()
  }

  private func updateChaptersRead() {
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

  @objc var name: String {
    return String(
      format: NSLocalizedString("Day %d", comment: "Day description format"),
      order
    )
  }

  var percentageRead: Double {
    return Double(chaptersRead) / Double(chapterCount)
  }

  @objc var weekName: String {
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
