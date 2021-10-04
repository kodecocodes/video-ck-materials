/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CloudKit

class NotesTableViewController: UITableViewController {
  // MARK: - Properties
  var notes: [Note] = []
  var establishment: Establishment?
  var dataSource: UITableViewDiffableDataSource<Int, Note>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataSource = notesDataSource()
    if establishment == nil {
      refreshControl = UIRefreshControl()
      refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
      refresh()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    reloadSnapshot(animated: false)
  }
  
  @objc private func refresh() {
    Task {
      do {
        notes = try await .init()
      } catch {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
      refreshControl?.endRefreshing()
      reloadSnapshot(animated: true)
    }
  }
}

extension NotesTableViewController {
  private func notesDataSource() -> UITableViewDiffableDataSource<Int, Note> {
    let reuseIdentifier = "NoteCell"
    return UITableViewDiffableDataSource(tableView: tableView) { (tableView, indexPath, note) -> UITableViewCell? in
      let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
      cell.textLabel?.text = note.noteLabel
      return cell
    }
  }
  
  private func reloadSnapshot(animated: Bool) {
    var snapshot = NSDiffableDataSourceSnapshot<Int, Note>()
    snapshot.appendSections([0])
    var isEmpty = false
    if let establishment = establishment {
      snapshot.appendItems(establishment.notes)
      isEmpty = establishment.notes.isEmpty
    } else {
      snapshot.appendItems(notes)
      isEmpty = notes.isEmpty
    }
    dataSource?.apply(snapshot, animatingDifferences: animated)
    if isEmpty {
      let label = UILabel()
      label.text = "No Notes Found"
      label.textColor = UIColor.systemGray2
      label.textAlignment = .center
      label.font = UIFont.preferredFont(forTextStyle: .title2)
      tableView.backgroundView = label
    } else {
      tableView.backgroundView = nil
    }
  }
}
