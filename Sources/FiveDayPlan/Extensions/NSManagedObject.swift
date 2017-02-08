import CoreData

extension NSObjectProtocol where Self: NSManagedObject {
  static func first(in context: NSManagedObjectContext) throws -> Self? {
    let request = fetchRequest() as! NSFetchRequest<Self>
    request.fetchLimit = 1
    return try context.fetch(request).first
  }
}
