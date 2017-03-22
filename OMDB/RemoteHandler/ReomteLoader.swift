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
    print("reomte search \(encodedString)")
    Alamofire.request(encodedString).responseJSON { response in
      print("alomofire \(response.result)")
      if let error = response.result.error {
        print("alamo error \(error)")
        //TODO network error
        responseDelegate.failureForPaging(index: pageIndex, error: error)
      } else {
        // repsonse OK
        let validResponse = response.result.value as! NSDictionary
        print("alamo success")
        if let responseData = validResponse["Search"] as? NSArray {
          // populate data
          var itemsArray = [OMDBItem]()
          for item in responseData {
            if let validItem = OMDBItem(fromDictionary: item as! NSDictionary) {
              itemsArray.append(validItem)
            }
          }
          print("alamo \(responseData.count)")
          if let totalResults = validResponse["totalResults"] as? String {
            print("alamo \(totalResults)")
            if let totalNumOfResults = Int(totalResults) {
              //TODO return data with number of pages
              responseDelegate.succesForPaging(index: pageIndex, response: SearchRepsponse(totalResults: totalNumOfResults, searchResults: itemsArray))
            } else {
              print("alamo here2")
              responseDelegate.succesForPaging(index: pageIndex, response: SearchRepsponse(totalResults: 0, searchResults: itemsArray))
            }
          } else {
            print("alamo here")
            //TODO return data. no next page
            responseDelegate.succesForPaging(index: pageIndex, response: SearchRepsponse(totalResults: 0, searchResults: itemsArray))
          }
        } else {
          // no data, movie not found / no more pages
          responseDelegate.succesForPaging(index: pageIndex, response: SearchRepsponse(totalResults: 0, searchResults: []))
        }
        
      }
    }
  }
  
  static func loadPlot(_ item: OMDBItem, responseDelegate: PlotResponseDelegate) {
    let encodedString = String(format: loadPlotStringFormat, item.itemId)
    Alamofire.request(encodedString).responseJSON(completionHandler: {
      (response) in
      print("alamo plot \(response)")
      if let error = response.result.error {
        responseDelegate.error(error.localizedDescription)
      } else {
        let rawResponse = response.result.value as! Dictionary<String, String>
        if let error = rawResponse["Error"] {
          print("alamo plot error \(error)")
          responseDelegate.error(error)
        } else {
          print("alamo plot success \(rawResponse)")
          let imdb = rawResponse["imdbID"]!
          let plot = rawResponse["Plot"]!
          let response = PlotResponse(plot: plot, imdbId: imdb)
          responseDelegate.success(response)
        }
      }
    })
  }
}
