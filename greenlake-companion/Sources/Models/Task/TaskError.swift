enum TaskError: Error {
  case loadFailed(Error)
  case createFailed(Error)
  case updateFailed(Error)
  case deleteFailed(Error)
}
