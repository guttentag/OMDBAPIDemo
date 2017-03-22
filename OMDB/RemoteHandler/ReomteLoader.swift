//
//  ReomteLoader.swift
//  OMDB
//
//  Created by Eran Guttentag on 3/19/17.
//  Copyright © 2017 Gutte. All rights reserved.
//

import Foundation
import Alamofire

class RemoteLoader {
  typealias SearchRepsponse = (totalResults: Int, searchResults: [OMDBItem])
  typealias PlotResponse = (plot: String, imdbId: String)
  static let searchUrlStringFormat = "https://omdbapi.com/?s=%@&page=%d"
  static let loadPlotStringFormat = "https://omdbapi.com/?i=%@&plot=full"
  
  static func searchWithIndex(queryString: String, pageIndex: Int, responseDelegate: SearchResponseDelegate) {
    let searchString = String(format: searchUrlStringFormat, queryString, pageIndex)
    let encodedString = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    Alamofire.request(encodedString).responseJSON { response in
      if let error = response.result.error {
        // network error:
        responseDelegate.failureForPaging(index: pageIndex, error: error)
      } else {
        // repsonse OK:
        let validResponse = response.result.value as! NSDictionary
        if let responseData = validResponse["Search"] as? NSArray {
          // populate data:
          var itemsArray = [OMDBItem]()
          for item in responseData {
            if let validItem = OMDBItem(fromDictionary: item as! NSDictionary) {
              itemsArray.append(validItem)
            }
          }
          if let totalResults = validResponse["totalResults"] as? String {
            if let totalNumOfResults = Int(totalResults) {
              //complete data with total results number:
              responseDelegate.succesForPaging(index: pageIndex, response: SearchRepsponse(totalResults: totalNumOfResults, searchResults: itemsArray))
            } else {
              // data with no total results number:
              responseDelegate.succesForPaging(index: pageIndex, response: SearchRepsponse(totalResults: 0, searchResults: itemsArray))
            }
          } else {
            // data with no total results number:
            responseDelegate.succesForPaging(index: pageIndex, response: SearchRepsponse(totalResults: 0, searchResults: itemsArray))
          }
        } else {
          // no data, movie not found / no more pages:
          responseDelegate.succesForPaging(index: pageIndex, response: SearchRepsponse(totalResults: 0, searchResults: []))
        }
      }
    }
  }
  
  static func loadPlot(_ item: OMDBItem, responseDelegate: PlotResponseDelegate) {
    let encodedString = String(format: loadPlotStringFormat, item.itemId)
    Alamofire.request(encodedString).responseJSON(completionHandler: {
      (response) in
        if let error = response.result.error {
          // network error:
          responseDelegate.error(error.localizedDescription)
        } else {
          let rawResponse = response.result.value as! Dictionary<String, String>
          if let error = rawResponse["Error"] {
            // could't find data:
            responseDelegate.error(error)
          } else {
            // found data:
            let imdb = rawResponse["imdbID"]!
            let plot = rawResponse["Plot"]!
            let response = PlotResponse(plot: plot, imdbId: imdb)
            responseDelegate.success(response)
          }
        }
    })
  }
}
