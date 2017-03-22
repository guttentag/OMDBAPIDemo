//
//  DetailViewController.swift
//  OMDB
//
//  Created by Eran Guttentag on 3/22/17.
//  Copyright © 2017 Gutte. All rights reserved.
//

import UIKit
import SafariServices

class DetailViewController: UIViewController {
  
  var omdbItem: OMDBItem!
  
  @IBOutlet weak var moreButton: UIButton!
  @IBOutlet weak var itemPlot: UILabel!
  @IBOutlet weak var itemImage: UIImageView!
  var imdbId: String?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.title = omdbItem.itemTitle
    initMoreButton()
    initPlot()
    initImage()
    RemoteLoader.loadPlot(omdbItem, responseDelegate: self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  func initMoreButton() {
    moreButton.layer.cornerRadius = 6
    moreButton.backgroundColor = moreButton.currentTitleColor
    moreButton.setTitleColor(UIColor.white, for: .normal)
    moreButton.setTitle("More...", for: .normal)
    moreButton.addTarget(self, action: #selector(self.moreButtonClicked), for: .touchUpInside)
    moreButton.isHidden = true
  }
  
  func initImage() {
    itemImage.contentMode = .scaleAspectFit
    itemImage.kf.setImage(with: omdbItem.posterUrl, placeholder: UIImage(named: "placeholder"), options: nil, progressBlock: nil, completionHandler: nil)
  }
  
  func initPlot() {
    itemPlot.text = "Loading plot..."
  }
  
  func moreButtonClicked(_ sender: Any?) {
    var schemeUrl: URL!
    var browserUrl: URL!
    if let id = imdbId {
      schemeUrl = URL(string: "imdb:///title/" + id)
      browserUrl = URL(string: "http://www.imdb.com/title/" + id)!
    } else {
      let encodedQuery = omdbItem.itemTitle.addingPercentEncoding(withAllowedCharacters: .whitespacesAndNewlines)!
      schemeUrl = URL(string: "imdb:///find?q=" + encodedQuery)
      browserUrl = URL(string: "http://www.imdb.com/find?q=" + encodedQuery)
    }
    if UIApplication.shared.canOpenURL(schemeUrl) {
      UIApplication.shared.open(schemeUrl, options: [:], completionHandler: nil)
    } else {
      let vc = SFSafariViewController(url: browserUrl)
      present(vc, animated: true, completion: nil)
    }
  }
}

extension DetailViewController: PlotResponseDelegate {
  func error(_ errMsg: String) {
    let msg = "Data was not loaded correctly. please try again later.\n Message: \(errMsg)"
    let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Got It", style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }
  
  func success(_ data: RemoteLoader.PlotResponse) {
    self.imdbId = data.imdbId
    UIView.transition(with: itemPlot, duration: 0.5, options: .transitionCrossDissolve, animations: {self.itemPlot.text = data.plot}, completion: nil)
    UIView.transition(with: moreButton, duration: 0.5, options: .transitionCrossDissolve, animations: {self.moreButton.isHidden = false}, completion: nil)
  }
}
