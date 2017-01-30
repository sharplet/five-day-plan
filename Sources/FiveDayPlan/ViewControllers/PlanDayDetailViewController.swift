import UIKit

final class PlanDayDetailViewController: UITableViewController {
  var details: PlanDayDetailViewModel!

  override func viewDidLoad() {
    super.viewDidLoad()

    title = details.title
  }

  override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return details.chapters.count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Chapters"
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let chapter = details.chapters[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Chapter", for: indexPath)
    cell.textLabel?.text = chapter.description
    return cell
  }
}
