//
//  CircleRankingView.swift
//  CircleRankingView
//
//  Created by Chung Han Hsin on 2020/6/4.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit
import HsinUtils

//MARK: - CircleRankingViewDataSource

public protocol CircleRankingViewDataSource: AnyObject {
  typealias LineModelTuple = (id: String, value: String, icon: String)
  
  func circleRankingViewNumberOfItemInRows(_ circleRankingView: CircleRankingView) -> Int
  func circleRankingViewRankingNodeViewWidth(_ circleRankingView: CircleRankingView) -> CGFloat
  func circleRankingViewOpacityDuration(_ circleRankingView: CircleRankingView) -> TimeInterval
  func circleRankingViewTotalDuration(_ circleRankingView: CircleRankingView) -> TimeInterval
  func circleRankingViewScale(_ circleRankingView: CircleRankingView) -> CGFloat
  func circleRankingViewLineModels(_ circleRankingView: CircleRankingView) -> [LineModelTuple]
  func circleRankingViewPadding(_ circleRankingView: CircleRankingView) -> CGFloat
  func circleRankingViewRoundDouration(_ circleRankingView: CircleRankingView) -> TimeInterval
}

//MARK: - CircleRankingViewDelegate

public protocol CircleRankingViewDelegate: AnyObject {
  
  func circleRankingViewOpacityGroupDidStop(_ circleRankingView: CircleRankingView, anim: CAAnimation)
  func circleRankingViewScaleAndTransationAnimationGroupDidStop(_ circleRankingView: CircleRankingView, anim: CAAnimation)
  func circleRankingViewTransationAnimationGroupDidStop(_ circleRankingView: CircleRankingView, anim: CAAnimation)
  func circleRankingViewTimerOnFire(_ circleRankingView: CircleRankingView)
  func circleRankingViewTimerDidInvalidate(_ circleRankingView: CircleRankingView)
}

//MARK: - CircleRankingView

public class CircleRankingView: UIView {
  
  public weak var dataSource: CircleRankingViewDataSource?
  public weak var delegate: CircleRankingViewDelegate?
  lazy var viewModel = makeViewModel()
  
  //MARK: - View lifeCycle
  
  override public func draw(_ rect: CGRect) {
    super.draw(rect)
    TimerManager.shared.dataSource = self
    TimerManager.shared.delegate = self
    TimerManager.shared.setupTimer()
  }
}

//MARK: - Lazy initialization

extension CircleRankingView {
  
  func makeRankingNodeView() -> RankingNodeView {
    let view = RankingNodeView()
    view.dataSource = self
    view.delegate = self
    return view
  }
  
  func makeViewModel() -> CircleRankingViewVM {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    
    
    let lineModelTuples = dataSource.circleRankingViewLineModels(self).reversed()
    var lineModels = [LineModel]()
    for tuple in lineModelTuples {
      let lineModel = LineModel(id: tuple.id, value: Float(tuple.value)!, icon: UIImage(named: tuple.icon)!)
      lineModels.append(lineModel)
    }
    let vm = CircleRankingViewVM(rawDataLineModels: lineModels)
    return vm
  }
}

//MARK: - RankingNodeViewDataSource

extension CircleRankingView: RankingNodeViewDataSource {
  
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
  
  func rankingNodeViewLineModel(_ rankingNodeView: RankingNodeView) -> LineModel {
    //TODO: - 之後設計 currentLineModel 為 nil 的狀況
    return viewModel.currentLineModel ?? LineModel(id: "", value: 99999, icon: UIImage())
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

//MARK: - TimerManagerDataSource

extension CircleRankingView: TimerManagerDataSource {
  
  public func timerManagerTimeInterval(_ timerManager: TimerManager) -> TimeInterval {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let duration = dataSource.circleRankingViewRoundDouration(self)
    return duration
  }
}


//MARK: - TimerManagerDelegate

extension CircleRankingView: TimerManagerDelegate {
  
  public func timerManagerFires(_ timerManager: TimerManager, timer: Timer) {
    delegate?.circleRankingViewTimerOnFire(self)
    guard let lineModel = viewModel.lineModelsPopLast(), let dataSource = dataSource else {
      timer.invalidate()
      return
    }
    //TODO: - 未來要在這邊把 rank 確定起來
    viewModel.updatePresentedRank(currentLineModel: lineModel)
    viewModel.presentedRankingNodeView.forEach {
      $0.doTransationAnimation()
    }
    
    let nodeView = makeRankingNodeView()
    addSubview(nodeView)
    let width = dataSource.circleRankingViewRankingNodeViewWidth(self)
    nodeView.anchor(top: nil, bottom: bottomAnchor, leading: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 20, right: 0), size: .init(width: width, height: width))
    nodeView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    nodeView.doOpacityAnimation()
    
    //這邊要判斷這個 nodeView 是否已經出現過，若已經出現過，則在做完 scaleAndTransation 的動畫要把自己移除。否則就保留，並加入到 presentedLineModels 和 presentedRankingNodeView
    if viewModel.isCurrentLineModelAlreadyExistInPresentedLineModels {
      viewModel.willRemoveCurrentNodeView()
    }else {
      viewModel.wontRemoveCurrentNodeView()
      viewModel.appendInPresentedLineModels(lineModel: lineModel)
      viewModel.appendInPresentedRankingNodeViews(rankingNodeView: nodeView)
    }
  }
  
  public func timerManagerInvalidate(_ timerManager: TimerManager) {
    delegate?.circleRankingViewTimerDidInvalidate(self)
  }
}
