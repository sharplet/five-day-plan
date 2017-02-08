import UIKit

final class PlanDayDetailViewController: UITableViewController {
  var details: PlanDayDetailViewModel!

  override func viewDidLoad() {
    super.viewDidLoad()

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
    cell.textLabel?.text = chapter.description
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    details.openChapter(at: indexPath) { _ in
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
}
