import CoreData

extension PlanDay {
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

    for scripture in scriptures.chapters {
      let chapter = PlanChapter(scripture: scripture, insertInto: context)
      addToChapters(chapter)
    }
  }

  var formattedSummary: String {
    return summary!
      .replacingOccurrences(of: "-", with: "–")
  }

  var name: String {
    return String(
      format: NSLocalizedString("Day %d", comment: "Day description format"),
      order
    )
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
