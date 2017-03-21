//
//  ItemType.swift
//  OMDB
//
//  Created by Eran Guttentag on 3/19/17.
//  Copyright © 2017 Gutte. All rights reserved.
//

import Foundation

enum ItemType {
  case Movie
  case Series
  case Episode
  case Other

  static func typeFrom(string: String) -> ItemType {
    switch string.lowercased() {
      case "movie":
        return ItemType.Movie
      case "series":
        return ItemType.Series
      case "episode":
        return ItemType.Episode
      default:
        return ItemType.Other
    }
  }
}
