//
//  PlotResponseDelegate.swift
//  OMDB
//
//  Created by Eran Guttentag on 3/22/17.
//  Copyright © 2017 Gutte. All rights reserved.
//

protocol PlotResponseDelegate {
  func error(_ errMsg: String)
  func success(_ data: RemoteLoader.PlotResponse)
}
