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

class DetailTableViewController: UITableViewController {
  // MARK: - Outlets
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var kidsMenuImageView: UIImageView!
  @IBOutlet private weak var healthyOptionImageView: UIImageView!
  @IBOutlet private weak var womensChangingLabel: UILabel!
  @IBOutlet private weak var mensChangingLabel: UILabel!
  
  // MARK: - Properties
  var establishment: Establishment?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  private func setup() {
    guard let establishment = establishment else { return }
    title = establishment.name
    let circleFill = "checkmark.circle.fill"
    let notAvailable = "xmark.circle"
    var kidsImageName = circleFill
    var healthyFoodName = circleFill
    if !establishment.kidsMenu {
      kidsImageName = notAvailable
    }
    if !establishment.healthyOption {
      healthyFoodName = notAvailable
    }
    kidsMenuImageView.image = UIImage(systemName: kidsImageName)
    healthyOptionImageView.image = UIImage(systemName: healthyFoodName)
    let changingTable = establishment.changingTable
    womensChangingLabel.alpha = (changingTable == .womens || changingTable == .both) ? 1.0 : 0.5
    mensChangingLabel.alpha = (changingTable == .mens || changingTable == .both) ? 1.0 : 0.5

    Task {
      imageView.image = try await establishment.loadCoverPhoto()
    }
  }
  
  // MARK: - Navigation
  @IBSegueAction private func notesSegue(coder: NSCoder, sender: Any?) -> NotesTableViewController? {
    guard let notesTableViewController = NotesTableViewController(coder: coder) else { return nil }
    notesTableViewController.establishment = establishment
    return notesTableViewController
  }
}
