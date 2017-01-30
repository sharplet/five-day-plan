struct ScriptureCollection {
  var chapters: [Scripture.Chapter] = []
  var summary: String
}

extension ScriptureCollection {
  init(summary: String) {
    self.summary = summary
  }
}
