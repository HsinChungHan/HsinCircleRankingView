//
//  RankingNodeViewVM.swift
//  CircleRankingView
//
//  Created by Chung Han Hsin on 2020/6/4.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit

class RankingNodeViewVM {
  private(set) var lineModel: CircleNodeModel
  let scaleWidth: CGFloat
  let numberOfRows: Int
  let padding: CGFloat
  
  var id: String {
    return lineModel.id
  }
  
  var icon: UIImage {
    return lineModel.icon
  }
  
  var teamLogo: UIImage? {
    return lineModel.teamLogo
  }
  
  private(set) var rank: Int
  
  var xIndex: Int {
    return rank % numberOfRows
  }
  
  var yIndex: Int {
    return rank / numberOfRows
  }
  
  private(set) var xFromValue: CGFloat
  var xToValue: CGFloat {
    //0.5 是指一半的 width
    return (CGFloat(xIndex) + 0.5) * scaleWidth + CGFloat(xIndex + 1) * padding
  }
  
  private(set) var yFromValue: CGFloat
  var yToValue: CGFloat {
    return (CGFloat(yIndex) + 0.5) * scaleWidth + CGFloat(yIndex + 1) * padding
  }
  
  
  init(lineModel: CircleNodeModel, numberOfItems: Int, scaleWidth: CGFloat, xFromValue: CGFloat, yFromValue: CGFloat, padding: CGFloat) {
    self.lineModel = lineModel
    self.rank = lineModel.rank
    self.scaleWidth = scaleWidth
    self.numberOfRows = numberOfItems
    self.xFromValue = xFromValue
    self.yFromValue = yFromValue
    self.padding = padding
  }
  
  func updateXYFromValue() {
    self.xFromValue = xToValue
    self.yFromValue = yToValue
  }
  
  func setRank(_ rank: Int) {
    self.rank = rank
  }
  
  func setLineModel(_ lineModel: CircleNodeModel) {
    self.lineModel = lineModel
  }
}
