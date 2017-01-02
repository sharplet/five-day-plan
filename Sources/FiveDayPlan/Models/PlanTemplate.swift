import Foundation

enum PlanTemplateError: Error {
  case missingTitle(String)
  case noSuchTemplate(name: String)
}

struct PlanTemplate {
  var weeks: [Week]

  init(name: String, bundle: Bundle = .main) throws {
    guard let url = bundle.url(forResource: name, withExtension: "txt", subdirectory: "Plans")
      else { throw PlanTemplateError.noSuchTemplate(name: name) }

    let string = try String(contentsOf: url)
    weeks = try string.blocks.map { try Week(text: $0) }
  }
}

extension PlanTemplate {
  struct Week {
    var title: String

    init(text: String) throws {
      guard let title = text.enumerated(.byLines).first else {
        throw PlanTemplateError.missingTitle(text)
      }

      self.title = title
    }
  }
}

extension PlanTemplate {
  static let year2017: PlanTemplate! = try? PlanTemplate(name: "2017")
}
