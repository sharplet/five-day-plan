import Foundation

enum PlanTemplateError: Error {
  case noSuchTemplate(name: String)
}

struct PlanTemplate {
  private let url: URL

  init(name: String, bundle: Bundle = .main) throws {
    guard let url = bundle.url(forResource: name, withExtension: "txt", subdirectory: "Plans")
      else { throw PlanTemplateError.noSuchTemplate(name: name) }
    self.url = url
  }
}

extension PlanTemplate {
  static let year2017: PlanTemplate! = try? PlanTemplate(name: "2017")
}
