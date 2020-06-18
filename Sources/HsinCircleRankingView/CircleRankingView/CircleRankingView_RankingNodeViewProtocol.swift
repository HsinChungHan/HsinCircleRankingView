//
//  CircleRankingView_RankingNodeViewProtocol.swift
//  RankingVisualiztionTool
//
//  Created by Chung Han Hsin on 2020/6/18.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit

//MARK: - RankingNodeViewDataSource

extension CircleRankingView: RankingNodeViewDataSource {
  func rankingNodeViewBackgroundColor(_ rankingNodeView: RankingNodeView) -> UIColor {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let color = dataSource.circleRankingViewRankingNodeViewBackgroundColor(self)
    return color
  }
  
  func rankingNodeViewXTransationToCircleRankingViewMidXDuration(_ rankingNodeView: RankingNodeView) -> TimeInterval {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let duration = dataSource.circleRankingViewNodeViewXTransationToMidXDuration(self)
    return duration
  }
  
  func rankingNodeViewCirecleRankingViewMidX(_ rankingNodeView: RankingNodeView) -> CGFloat {
    return bounds.midX
  }
  
  
  func rankingNodeViewPadding(_ rankingNodeView: RankingNodeView) -> CGFloat {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let padding = dataSource.circleRankingViewPadding(self)
    return padding
  }
  
  func rankingNodeViewCircleRankingViewNumberOfItemsInRows(_ rankingNodeView: RankingNodeView) -> Int {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let items = dataSource.circleRankingViewNumberOfItemInRows(self)
    return items
  }
  
  func rankingNodeViewWidth(_ rankingNodeView: RankingNodeView) -> CGFloat {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let width = dataSource.circleRankingViewRankingNodeViewWidth(self)
    return width
  }
  
  func rankingNodeViewOpacityDuration(_ rankingNodeView: RankingNodeView) -> TimeInterval {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let duration = dataSource.circleRankingViewOpacityDuration(self)
    return duration
  }
  
  func rankingNodeViewTotalDuration(_ rankingNodeView: RankingNodeView) -> TimeInterval {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let duration = dataSource.circleRankingViewTotalDuration(self)
    return duration
  }
  
  func rankingNodeViewScale(_ rankingNodeView: RankingNodeView) -> CGFloat {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let scale = dataSource.circleRankingViewScale(self)
    return scale
  }
  
  func rankingNodeViewCircleNodelModel(_ rankingNodeView: RankingNodeView) -> CircleNodeModel {
    //TODO: - 之後設計 currentLineModel 為 nil 的狀況
    return viewModel.currentCircleNodeModel ?? CircleNodeModel(id: "", value: 99999, icon: UIImage(), teamLogo: nil)
  }
  
  func rankingNodeViewMidX(_ rankingNodeView: RankingNodeView) -> CGFloat {
    layoutIfNeeded()
    return rankingNodeView.bounds.midX
  }
  
  func rankingNodeViewMidY(_ rankingNodeView: RankingNodeView) -> CGFloat {
    layoutIfNeeded()
    return rankingNodeView.bounds.midY
  }
}

//MARK: - RankingNodeViewDelegate

extension CircleRankingView: RankingNodeViewDelegate {
  func rankingNodeViewXTransationGroupDidStop(_ rankingNodeView: RankingNodeView, anim: CAAnimation) {
    delegate?.circleRankingViewXTransationGroupDidStop(self
      , anim: anim)
  }
  
  
  func rankingNodeViewOpacityGroupDidStop(_ rankingNodeView: RankingNodeView, anim: CAAnimation) {
    delegate?.circleRankingViewOpacityGroupDidStop(self, anim: anim)
  }
  
  func rankingNodeViewScaleAndTransationAnimationGroupDidStop(_ rankingNodeView: RankingNodeView, anim: CAAnimation) {
    if viewModel.isRemovedCurrentNodeView {
      rankingNodeView.removeFromSuperview()
    }
    delegate?.circleRankingViewTransationAnimationGroupDidStop(self, anim: anim)
  }
  
  func rankingNodeViewTransationAnimationGroupDidStop(_ rankingNodeView: RankingNodeView, anim: CAAnimation) {
    delegate?.circleRankingViewTransationAnimationGroupDidStop(self, anim: anim)
  }
}
