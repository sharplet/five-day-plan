import UIKit

final class PlanOutlineViewController: UITableViewController {
  let store = Store.shared
  let viewModel = PlanOutlineViewModel(plan: .year2017)

  private var state = InitialisationState.uninitialised

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    initialisePlan()
  }

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
    let week = viewModel[indexPath]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Day Summary", for: indexPath)
    cell.textLabel?.text = week.title
    cell.detailTextLabel?.text = week.subtitle
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let week = viewModel.sections[indexPath.section]
    navigationItem.backBarButtonItem = UIBarButtonItem(title: week.title, style: .plain, target: nil, action: nil)
    perform(.showDayDetail) {
      $0.details = self.viewModel[indexPath].dayDetails
    }
  }

  private func initialisePlan() {
    guard state.isUninitialised else { return }

    state = .loading

    store.initialisePlan { error in
      if let error = error {
        self.state = .uninitialised
        self.show(error)
      } else {
        self.state = .initialised
      }
    }
  }
}

private enum InitialisationState {
  case uninitialised
  case loading
  case initialised

  var isUninitialised: Bool {
    switch self {
    case .uninitialised:
      return true
    case .loading, .initialised:
      return false
    }
  }
}
