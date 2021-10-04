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
import CoreLocation

class NearbyTableViewController: UITableViewController {
  var locationManager: CLLocationManager!
  var dataSource: UITableViewDiffableDataSource<Int, Establishment>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLocationManager()
    dataSource = establishmentDataSource()
    tableView.dataSource = dataSource
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    refresh()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    reloadSnapshot(animated: false)
  }
  
  @objc private func refresh() {
    Task {
      do {
        try await Model.current.refresh()
        tableView.refreshControl?.endRefreshing()
        reloadSnapshot(animated: true)
      } catch {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        tableView.refreshControl?.endRefreshing()
      }
    }
  }

  // MARK: - Navigation
  @IBSegueAction private func detailSegue(coder: NSCoder, sender: Any?) -> DetailTableViewController? {
    guard
      let cell = sender as? NearbyCell,
      let indexPath = tableView.indexPath(for: cell),
      let detailViewController = DetailTableViewController(coder: coder)
      else { return nil }
    detailViewController.establishment = Model.current.establishments[indexPath.row]
    return detailViewController
  }
}

extension NearbyTableViewController {
  private func establishmentDataSource() -> UITableViewDiffableDataSource<Int, Establishment> {
    let reuseIdentifier = "NearbyCell"
    return UITableViewDiffableDataSource(tableView: tableView) { (tableView, indexPath, establishment) -> NearbyCell? in
      let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? NearbyCell
      cell?.establishment = establishment
      return cell
    }
  }
  
  private func reloadSnapshot(animated: Bool) {
    var snapshot = NSDiffableDataSourceSnapshot<Int, Establishment>()
    snapshot.appendSections([0])
    snapshot.appendItems(Model.current.establishments)
    dataSource?.apply(snapshot, animatingDifferences: animated)
    if Model.current.establishments.isEmpty {
      let label = UILabel()
      label.text = "No Restaurants Found"
      label.textColor = UIColor.systemGray2
      label.textAlignment = .center
      label.font = UIFont.preferredFont(forTextStyle: .title2)
      tableView.backgroundView = label
    } else {
      tableView.backgroundView = nil
    }
  }
}

// MARK: - CLLocationManagerDelegate
extension NearbyTableViewController: CLLocationManagerDelegate {
  func setupLocationManager() {
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    
    // Only look at locations within a 0.5 km radius.
    locationManager.distanceFilter = 500.0
    locationManager.delegate = self
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)  {
    switch status {
    case .notDetermined:
      manager.requestWhenInUseAuthorization()
    case .authorizedWhenInUse:
      manager.startUpdatingLocation()
    default:
      // Do nothing.
      print("Other status")
    }
  }
}
