//
//  SearchInteractionDelegate.swift
//  OMDB
//
//  Created by Eran Guttentag on 3/22/17.
//  Copyright © 2017 Gutte. All rights reserved.
//

protocol SearchInteractionDelegate {
  func showItemDetails(_ item: OMDBItem)
  func displayError(_ msg: String)
}
