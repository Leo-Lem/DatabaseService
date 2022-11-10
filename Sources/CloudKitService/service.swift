//	Created by Leopold Lemmermann on 23.10.22.

import CloudKit
import Combine
import Queries
import RemoteDatabaseService

open class CloudKitService: RemoteDatabaseService {
  public internal(set) var status: RemoteDatabaseStatus = .unavailable
  
  public let didChange = PassthroughSubject<RemoteDatabaseChange, Never>()

  let container: CKContainer
  private let scope: CKDatabase.Scope
  var database: CKDatabase { container.database(with: scope) }

  private let tasks = Tasks()

  public init(_ container: CKContainer, scope: CKDatabase.Scope = .public) async {
    self.container = container
    self.scope = scope
    
    tasks.add(statusUpdateOnCloudKitChange(), periodicRefresh(every: 60))
    
    await updateStatus()
  }

  @discardableResult
  public func publish<T: RemoteModelConvertible>(_ convertible: T) async throws -> T {
    try await mapToCloudKitError {
      try await database.save(
        try verifyIsCKRecord(remoteModel: try await mapToRemoteModel(convertible))
      )
      
      didChange.send(.published(convertible))
      
      return convertible
    }
  }

  public func unpublish<T: RemoteModelConvertible>(with id: String, _: T.Type = T.self) async throws {
    try await mapToCloudKitError {
      try await database.deleteRecord(withID: CKRecord.ID(recordName: id))
      didChange.send(.unpublished(T.self))
    }
  }

  public func fetch<T: RemoteModelConvertible>(_ query: Query<T>) -> AsyncThrowingStream<T, Error> {
    fetch(query)
      .map(T.init)
      .mapError(mapToCloudKitError)
  }
}