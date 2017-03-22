//
//  SearchTableViewDataSource.swift
//  OMDB
//
//  Created by Eran Guttentag on 3/19/17.
//  Copyright © 2017 Gutte. All rights reserved.
//

import UIKit
import Kingfisher

class SearchTableViewDataSource: NSObject, UITableViewDataSource {
  let itemCellDequeIdentifier = "itemCellViewIdentifier"
  let pageSize: Int = 10
  var data = [OMDBItem]()
  var currentLoadedIndex: Int = 1
  var maxNumberOfPages = 0
  var tableView: UITableView?
  var currentQueryString: String?
  var searchInteractionDelegate: SearchInteractionDelegate?
  
  var nextPageAvailable: Bool {
    get {
      return currentLoadedIndex <= maxNumberOfPages
    }
  }
  
  init(table: UITableView, eventDelegate: SearchInteractionDelegate) {
    super.init()
    self.searchInteractionDelegate = eventDelegate
    self.tableView = table
    self.tableView!.rowHeight = 80
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return nextPageAvailable ? data.count + 1 : data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row < data.count {
      // regular data cell
      var cell = tableView.dequeueReusableCell(withIdentifier: self.itemCellDequeIdentifier)
      if cell == nil {
        cell = generateNewCell()
      }
      let dataItem = self.data[indexPath.row]
      return populateCellWithData(cell: cell!, data: dataItem)
    } else {
      // loading indicator cell:
      let cell = tableView.dequeueReusableCell(withIdentifier: "LoadinCellIdentifier", for: indexPath)
      let indicator = cell.contentView.subviews[0] as! UIActivityIndicatorView
      indicator.startAnimating()
      RemoteLoader.searchWithIndex(queryString: currentQueryString!, pageIndex: currentLoadedIndex, responseDelegate: self)
      return cell
    }
  }
  
  func populateCellWithData(cell: UITableViewCell, data: OMDBItem) -> UITableViewCell {
    cell.textLabel?.text = data.itemTitle
    cell.detailTextLabel?.text = data.itemYear.description
    if let imageUrl = data.posterUrl {
      cell.imageView?.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder_v"), options: nil, progressBlock: nil, completionHandler: nil)
    }
    return cell
  }
  
  func generateNewCell() -> UITableViewCell{
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: self.itemCellDequeIdentifier)
    cell.textLabel?.numberOfLines = 3
    cell.textLabel?.lineBreakMode = .byTruncatingTail
    cell.imageView?.contentMode = .scaleAspectFit
    return cell
  }
  
  func loadNewDataFor(_ searchString: String) {
    self.currentLoadedIndex = 1
    self.maxNumberOfPages = 0
    self.data.removeAll()
    tableView?.reloadData()
    self.currentQueryString = searchString
    RemoteLoader.searchWithIndex(queryString: searchString, pageIndex: currentLoadedIndex, responseDelegate: self)
  }
}

extension SearchTableViewDataSource: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    searchInteractionDelegate?.showItemDetails(data[indexPath.row])
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension SearchTableViewDataSource: SearchResponseDelegate {
  func succesForPaging(index: Int, response: RemoteLoader.SearchRepsponse) {
    self.maxNumberOfPages = (response.totalResults / pageSize) + 1
    currentLoadedIndex = index + 1
    self.data.append(contentsOf: response.searchResults)
    self.tableView?.reloadData()
  }
  
  func failureForPaging(index: Int, error: Error) {
    searchInteractionDelegate?.displayError("Search Error, plese check your connectivity.\n Message: \(error.localizedDescription)")
  }
}

