import struct Foundation.IndexPath

final class PlanOutlineViewModel {
  private(set) var sections: [PlanOutlineSection]

  init(plan: PlanTemplate) {
    sections = plan.weeks.map(PlanOutlineSection.init)
  }

  func numberOfRows(inSection section: Int) -> Int {
    return sections[section].rows.count
  }

  subscript(indexPath: IndexPath) -> PlanOutlineRow {
    return sections[indexPath.section].rows[indexPath.row]
  }
}

struct PlanOutlineSection {
  let title: String

  private(set) var rows: [PlanOutlineRow]

  init(week: PlanTemplate.Week) {
    title = week.title
    rows = week.days.enumerated().map { offset, scriptures in
      PlanOutlineRow(title: "Day \(offset + 1)", scriptures: scriptures)
    }
  }
}

struct PlanOutlineRow {
  let title: String
  let subtitle: String?

  init(title: String, scriptures: ScriptureCollection) {
    self.title = title
    self.subtitle = scriptures.formattedSummary
  }
}

private extension ScriptureCollection {
  var formattedSummary: String {
    return summary
      .replacingOccurrences(of: "-", with: "–")
  }
}
