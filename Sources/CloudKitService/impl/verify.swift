//	Created by Leopold Lemmermann on 09.11.22.

import CloudKit
import RemoteDatabaseService

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension CloudKitService {
  func verifyIsRemoteModel<T: RemoteModelConvertible, U>(_ object: U, _: T.Type = T.self) throws -> T.RemoteModel {
    guard let remoteModel = object as? T.RemoteModel else {
      throw RemoteDatabaseError.mapping(invalidRemoteModel: T.RemoteModel.self)
    }

    return remoteModel
  }
  
  func verifyIsCKRecord<T>(remoteModel: T) throws -> CKRecord {
    guard let object = remoteModel as? CKRecord else {
      throw RemoteDatabaseError.mapping(invalidRemoteModel: T.self)
    }

    return object
  }

  func verifyRemoteModelIsCKRecord<T: RemoteModelConvertible>(_: T.Type = T.self) throws {
    guard T.RemoteModel.self is CKRecord.Type else {
      throw RemoteDatabaseError.mapping(invalidRemoteModel: T.RemoteModel.self)
    }
  }
}
