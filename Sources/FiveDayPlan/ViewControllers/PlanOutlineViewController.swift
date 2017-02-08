import CoreData
import UIKit

final class PlanOutlineViewController: UITableViewController {
  let viewModel = PlanOutlineViewModel(plan: .year2017, store: .shared)

  override func viewDidLoad() {
    super.viewDidLoad()

    viewModel.fetchController.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    initialise()
    performFetch()
  }

  private func initialise() {
    viewModel.initialise { error in
      if let error = error {
        self.show(error)
      }
    }
  }

  private func performFetch() {
    do {
      try viewModel.performFetch()
    } catch {
      show(error)
    }
  }

  override func numberOfSections(in _: UITableView) -> Int {
    return viewModel.numberOfSections
  }

  override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRows(inSection: section)
  }

  override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
    return viewModel.titleForHeader(inSection: section)
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let day = viewModel[indexPath]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Day Summary", for: indexPath)
    cell.textLabel?.text = day.name
    cell.detailTextLabel?.text = day.formattedSummary
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let weekTitle = viewModel.titleForHeader(inSection: indexPath.section)
    navigationItem.backBarButtonItem = UIBarButtonItem(title: weekTitle, style: .plain, target: nil, action: nil)
    perform(.showDayDetail) {
      $0.details = self.viewModel.dayDetails(at: indexPath)
    }
  }
}

extension PlanOutlineViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }

  func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange _: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      tableView.insertSections([sectionIndex], with: .fade)
    default:
      fatalError("unexpected section change type: \(type)")
    }
  }

  func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}
