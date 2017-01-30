import UIKit

struct YouVersionScriptureProvider: ScriptureProvider {
  private let application: UIApplication

  init(application: UIApplication = .shared) {
    self.application = application
  }

  func open(_ chapter: Scripture.Chapter, completionHandler: @escaping (Bool) -> Void) {
    let url = chapterURL(for: chapter)
    application.open(url, completionHandler: completionHandler)
  }

  private func chapterURL(for chapter: Scripture.Chapter) -> URL {
    let reference = "\(chapter.book.osisAbbrevation).\(chapter.chapter ?? 1)"

    var components = URLComponents(string: "youversion://bible")!
    components.queryItems = [
      URLQueryItem(name: "reference", value: reference),
    ]

    return components.url!
  }
}
