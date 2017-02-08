import CoreData
import UIKit

final class PlanDayDetailViewController: UITableViewController {
  var details: PlanDayDetailViewModel!

  override func viewDidLoad() {
    super.viewDidLoad()

    details.fetchController.delegate = self
    title = details.title
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    do {
      try details.performFetch()
    } catch {
      show(error)
    }
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return details.numberOfSections
  }

  override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    return details.numberOfChapters(in: section)
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Chapters"
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let chapter = details[indexPath]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Chapter", for: indexPath)
    cell.textLabel?.text = chapter.name
    cell.accessoryType = chapter.isRead ? .checkmark : .none
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    details.openChapter(at: indexPath) { error in
      tableView.deselectRow(at: indexPath, animated: true)

      if let error = error {
        self.show(error)
      }
    }
  }
}

extension PlanDayDetailViewController: NSFetchedResultsControllerDelegate {
  func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange _: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath _: IndexPath?) {
    switch type {
    case .update:
      tableView.reloadRows(at: [indexPath!], with: .none)
    default:
      fatalError("unexpected object change type: \(type.rawValue)")
    }
  }
}
