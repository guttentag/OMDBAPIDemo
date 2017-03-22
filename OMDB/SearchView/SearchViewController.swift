//
//  SearchViewController.swift
//  OMDB
//
//  Created by Eran Guttentag on 3/19/17.
//  Copyright © 2017 Gutte. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  var searchTableDataSource: SearchTableViewDataSource?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.topItem?.title = "OMDB API"
    searchBar.showsCancelButton = true
    searchBar.delegate = self
    searchTableDataSource = SearchTableViewDataSource(table:self.tableView, eventDelegate: self)
    let uiButton = searchBar.value(forKey: "cancelButton") as! UIButton
    uiButton.setTitle("Go !", for: .normal)
    tableView.dataSource = searchTableDataSource
    tableView.delegate = searchTableDataSource
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
//TODO empty search string
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchFor(searchBar.text!)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchFor(searchBar.text!)
  }
  
  func searchFor(_ text: String) {
    let searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if searchText.characters.count < 3 {
      displayError("Search text must be at least 3 characters")
    } else {
      self.searchTableDataSource?.loadNewDataFor(searchText)
    }
  }
}
extension SearchViewController: SearchInteractionDelegate {
    func displayError(_ msg: String) {
      let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: "Got It", style: .cancel, handler: nil)
      alertController.addAction(cancelAction)
      present(alertController, animated: true, completion: nil)
    }
  
  func showItemDetails(_ item: OMDBItem) {
    print("show \(item)")
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
    vc.omdbItem = item
    navigationController?.pushViewController(vc, animated: true)
  }
}
