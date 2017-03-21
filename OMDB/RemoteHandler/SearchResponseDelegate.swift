//
//  SearchResponseDelegate.swift
//  OMDB
//
//  Created by Eran Guttentag on 3/19/17.
//  Copyright © 2017 Gutte. All rights reserved.
//

import Foundation

protocol SearchResponseDelegate {
  func succesForPaging(index: Int, response: RemoteLoader.SearchRepsponse)
  func failureForPaging(index: Int, error: Error)
}
