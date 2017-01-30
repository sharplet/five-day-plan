import UIKit

final class PlanOutlineViewController: UITableViewController {
  let viewModel = PlanOutlineViewModel(plan: .year2017)

  override func numberOfSections(in _: UITableView) -> Int {
    return viewModel.sections.count
  }

  override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRows(inSection: section)
  }

  override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
    return viewModel.sections[section].title
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = viewModel[indexPath]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Day Summary", for: indexPath)
    cell.textLabel?.text = row.title
    cell.detailTextLabel?.text = row.subtitle
    return cell
  }
}
