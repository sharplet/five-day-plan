import CoreData

extension Plan {
  convenience init(fromTemplate template: PlanTemplate, insertInto context: NSManagedObjectContext?) {
    self.init(entity: type(of: self).entity(), insertInto: context)

    for (weekOffset, week) in template.weeks.enumerated() {
      for (dayOffset, scriptures) in week.days.enumerated() {
        addToDays(
          PlanDay(
            scriptures: scriptures,
            order: dayOffset + 1,
            week: weekOffset + 1,
            insertInto: context
          )
        )
      }
    }
  }
}
