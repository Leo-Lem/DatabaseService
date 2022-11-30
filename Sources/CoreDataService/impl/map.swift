//	Created by Leopold Lemmermann on 08.11.22.

import Queries_NSPredicate

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension CoreDataService {
  func getDatabaseObject<T: Convertible>(from convertible: T) -> T.DatabaseObject {
    var object = fetchDatabaseObject(of: T.self, with: convertible.id) ?? create(T.self, with: convertible.id)
    convertible.mapProperties(onto: &object)
    return object
  }

  // TODO: map the id onto the database object automatically
  func create<T: Convertible>(_: T.Type, with id: T.ID) -> T.DatabaseObject {
    NSEntityDescription.insertNewObject(forEntityName: T.typeID, into: container.viewContext)
      .castToDatabaseObject(of: T.self)
  }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension NSFetchRequestResult {
  static func castFrom(databaseObject: Any) -> Self {
    guard let object = databaseObject as? Self else {
      fatalError("Your database object (\(type(of: databaseObject))) is incompatible.")
    }

    return object
  }

  func castToDatabaseObject<T: CoreDataService.Convertible>(of: T.Type) -> T.DatabaseObject {
    guard let databaseObject = self as? T.DatabaseObject else {
      fatalError("Your database object (\(T.DatabaseObject.self)) is incompatible.")
    }

    return databaseObject
  }
}