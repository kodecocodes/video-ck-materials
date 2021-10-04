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
import MapKit
import CloudKit
import CoreLocation

class Establishment {
  enum ChangingTable: Int {
    case none
    case womens
    case mens
    case both
  }
  
  static let recordType = "Establishment"
  private let id: CKRecord.ID
  let name: String
  let location: CLLocation
  let coverPhoto: CKAsset?
  let database: CKDatabase
  let changingTable: ChangingTable
  let kidsMenu: Bool
  let healthyOption: Bool
  let notes: [Note]
  
  init?(record: CKRecord, database: CKDatabase) async throws {
    guard
      let name = record["name"] as? String,
      let location = record["location"] as? CLLocation
    else { return nil }

    id = record.recordID
    self.name = name
    self.location = location
    coverPhoto = record["coverPhoto"] as? CKAsset
    self.database = database
    healthyOption = record["healthyOption"] as? Bool ?? false
    kidsMenu = record["kidsMenu"] as? Bool ?? false

    self.changingTable =
      (record["changingTable"] as? Int).flatMap(ChangingTable.init)
      ?? .none


    notes = []
  }

  func loadCoverPhoto() async throws -> UIImage? {
    nil
  }
}

extension Establishment: Hashable {
  static func == (lhs: Establishment, rhs: Establishment) -> Bool {
    return lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
