protocol ScriptureProvider {
  func open(_ chapter: Scripture.Chapter, completionHandler: @escaping (Bool) -> Void)
}
