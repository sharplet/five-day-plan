import CircleProgressView
import CoreData
import UIKit

private let sectionHeaderLabelAdjustment = 18 as CGFloat

final class PlanOutlineViewController: UITableViewController {
  let viewModel = PlanOutlineViewModel(plan: .year2017, store: .shared)

  private var isFirstLoad = true

  override func viewDidLoad() {
    super.viewDidLoad()

    viewModel.fetchController.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    initialise()
    performFetch()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    defer { isFirstLoad = false }

    if isFirstLoad, let indexPath = viewModel.indexPathForCurrentWeek() {
      tableView.scrollToRow(at: indexPath, at: .top, animated: false)
      tableView.contentOffset.y -= sectionHeaderLabelAdjustment
    }
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "Day Summary", for: indexPath) as! DaySummaryCell
    cell.textLabel?.text = day.name
    cell.textLabel?.textColor = day.isComplete ? .lightGray : nil
    cell.detailTextLabel?.textColor = day.isComplete ? .lightGray : nil
    cell.detailTextLabel?.text = day.formattedSummary
    cell.progressView?.isHidden = !day.isInProgress
    cell.progressView?.progress = day.percentageRead
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

  func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange _: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .update:
      tableView.reloadRows(at: [indexPath!], with: .none)
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .fade)
    default:
      fatalError("unexpected row change type: \(type.rawValue)")
    }
  }

  func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange _: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      tableView.insertSections([sectionIndex], with: .fade)
    default:
      fatalError("unexpected section change type: \(type.rawValue)")
    }
  }

  func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}
