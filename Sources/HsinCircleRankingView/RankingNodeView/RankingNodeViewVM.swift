//
//  RankingNodeViewVM.swift
//  CircleRankingView
//
//  Created by Chung Han Hsin on 2020/6/4.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit

class RankingNodeViewVM {
  private(set) var circleNodeModel: CircleNodeModel
  let scaleWidth: CGFloat
  let numberOfRows: Int
  let padding: CGFloat
  
  var id: String {
    return circleNodeModel.id
  }
  
  var icon: UIImage {
    return circleNodeModel.icon
  }
  
  var teamLogo: UIImage? {
    return circleNodeModel.teamLogo
  }
  
  private(set) var rank: Int
  
  var xIndex: Int {
    return rank % numberOfRows
  }
  
  var yIndex: Int {
    return rank / numberOfRows
  }
  
  private(set) var xRankingOrderFromValue: CGFloat
  var xRankingOrderToValue: CGFloat {
    //0.5 是指一半的 width
    return (CGFloat(xIndex) + 0.5) * scaleWidth + CGFloat(xIndex + 1) * padding
  }
  
  private(set) var yRankingOrderFromValue: CGFloat
  var yRankingOrderToValue: CGFloat {
    return (CGFloat(yIndex) + 0.5) * scaleWidth + CGFloat(yIndex + 1) * padding
  }
  
  
  init(circleNodelModel: CircleNodeModel, numberOfItems: Int, scaleWidth: CGFloat, xFromValue: CGFloat, yFromValue: CGFloat, padding: CGFloat) {
    self.circleNodeModel = circleNodelModel
    self.rank = circleNodelModel.rank
    self.scaleWidth = scaleWidth
    self.numberOfRows = numberOfItems
    self.xRankingOrderFromValue = xFromValue
    self.yRankingOrderFromValue = yFromValue
    self.padding = padding
  }
  
  func updateXFromValue(fromValue: CGFloat) {
    self.xRankingOrderFromValue = fromValue
  }
  
  func updateXYFromValue() {
    self.xRankingOrderFromValue = xRankingOrderToValue
    self.yRankingOrderFromValue = yRankingOrderToValue
  }
  
  func setRank(_ rank: Int) {
    self.rank = rank
  }
  
  func setCircleNodeModel(_ circleNodeModel: CircleNodeModel) {
    self.circleNodeModel = circleNodeModel
  }
}
