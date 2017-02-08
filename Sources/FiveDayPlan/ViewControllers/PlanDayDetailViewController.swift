import UIKit

final class PlanDayDetailViewController: UITableViewController {
  var details: PlanDayDetailViewModel!

  override func viewDidLoad() {
    super.viewDidLoad()

    title = details.title
  }

  override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return details.numberOfChapters
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Chapters"
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let chapter = details[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Chapter", for: indexPath)
    cell.textLabel?.text = chapter.description
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    details.openChapter(at: indexPath.row) { _ in
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
}
