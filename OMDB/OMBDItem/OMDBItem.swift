//
//  OMDBItem.swift
//  OMDB
//
//  Created by Eran Guttentag on 3/19/17.
//  Copyright © 2017 Gutte. All rights reserved.
//

import Foundation

class OMDBItem {
  let itemType: ItemType
  let itemId: String
  var posterUrl: URL?
  var itemYear: Int
  var itemTitle: String
  
  init(id: String, type: ItemType, title: String, year: Int) {
    self.itemId = id
    self.itemType = type
    self.itemYear = year
    self.itemTitle = title
  }
  
  init?(fromDictionary dictionary: NSDictionary) {
//    print("Item \(dictionary)")
    if let id = dictionary["imdbID"] as? String {
      self.itemId = id
    } else {
      return nil
    }
    if let title = dictionary["Title"] as? String {
      self.itemTitle = title
    } else {
      return nil
    }
    if let type = dictionary["Type"] as? String {
      self.itemType = ItemType.typeFrom(string: type)
    } else {
      return nil
    }
    if let yearString = dictionary["Year"] as? String {
      if let year = Int(yearString) {
        self.itemYear = year
      } else {
        return nil
      }
    } else {
      return nil
    }
    if let poster = dictionary["Poster"] as? String {
      self.posterUrl = URL(string: poster)
    }
  }
}

extension OMDBItem: Hashable {
  var hashValue: Int {
    get {
      return self.itemId.hashValue
    }
  }
  
  static func == (lhs: OMDBItem, rhs: OMDBItem) -> Bool {
    return lhs.itemId == rhs.itemId
  }
}

