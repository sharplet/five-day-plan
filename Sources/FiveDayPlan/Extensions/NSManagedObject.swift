import CoreData

extension NSObjectProtocol where Self: NSManagedObject {
  static func fetch(by objectID: NSManagedObjectID, in context: NSManagedObjectContext) -> Self {
    return context.object(with: objectID) as! Self
  }

  static func first(in context: NSManagedObjectContext) throws -> Self? {
    let request = fetchRequest() as! NSFetchRequest<Self>
    request.fetchLimit = 1
    return try context.fetch(request).first
  }
}
