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
  
  func circleRankingViewNumberOfItemInRows(_ circleRankingView: CircleRankingView) -> Int
  func circleRankingViewRankingNodeViewWidth(_ circleRankingView: CircleRankingView) -> CGFloat
  func circleRankingViewOpacityDuration(_ circleRankingView: CircleRankingView) -> TimeInterval
  func circleRankingViewNodeViewXTransationToMidXDuration(_ circleRankingView: CircleRankingView) -> TimeInterval
  func circleRankingViewTotalDuration(_ circleRankingView: CircleRankingView) -> TimeInterval
  func circleRankingViewScale(_ circleRankingView: CircleRankingView) -> CGFloat
  func circleRankingViewLineModels(_ circleRankingView: CircleRankingView) -> [(id: String, value: Float, icon: String, teamLogo: String?, description: String)]
  func circleRankingViewPadding(_ circleRankingView: CircleRankingView) -> CGFloat
  func circleRankingViewRoundDouration(_ circleRankingView: CircleRankingView) -> TimeInterval
  func circleRankingViewRankingNodeViewBackgroundColor(_ circleRankingView: CircleRankingView) -> UIColor
  func circleRankingViewBackgroundImage(_ circleRankingView: CircleRankingView) -> UIImage
  func circleRankingViewBlurEffectStyle(_ circleRankingView: CircleRankingView) -> UIBlurEffect.Style
}

//MARK: - CircleRankingViewDelegate

public protocol CircleRankingViewDelegate: AnyObject {
  
  func circleRankingViewOpacityGroupDidStop(_ circleRankingView: CircleRankingView, anim: CAAnimation)
  func circleRankingViewXTransationGroupDidStop(_ circleRankingView: CircleRankingView, anim: CAAnimation)
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
  lazy var backgrounImageView = makeBackgrounImageView()
  lazy var blurEffectView = makeVisualEffectView()
  var timer: Timer?
  
  //MARK: - View lifeCycle
  
  override public func draw(_ rect: CGRect) {
    super.draw(rect)
    addSubview(backgrounImageView)
    backgrounImageView.fillSuperView()
    layoutIfNeeded()
    blurEffectView.frame = backgrounImageView.bounds
    backgrounImageView.addSubview(blurEffectView)
    
    timer = makeTimer()
    RunLoop.current.add(timer!, forMode: .common)
  }
}

//MARK: - Lazy initialization

extension CircleRankingView {
  
  fileprivate func makeVisualEffectView() -> UIVisualEffectView {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let effectStyle = dataSource.circleRankingViewBlurEffectStyle(self)
    let blurEffect = UIBlurEffect(style: effectStyle)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    return blurEffectView
  }
  
  fileprivate func makeBackgrounImageView() -> UIImageView {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let backgroundImage = dataSource.circleRankingViewBackgroundImage(self)
    let imv = UIImageView()
    imv.contentMode = .scaleAspectFill
    imv.image = backgroundImage
    imv.clipsToBounds = true
    return imv
  }
  
  func makeRankingNodeView(type: NodeType) -> RankingNodeView {
    let view = RankingNodeView(nodeType: type)
    view.dataSource = self
    view.delegate = self
    return view
  }
  
  func makeViewModel() -> CircleRankingViewVM {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    
    let lineModelTuples = dataSource.circleRankingViewLineModels(self)
    var lineModels = [CircleNodeModel]()
    for tuple in lineModelTuples {
      if let teamLogo = tuple.teamLogo {
        let circleNodeModel = CircleNodeModel(id: tuple.id, value: tuple.value, icon: UIImage(named: tuple.icon)!, teamLogo: UIImage(named: teamLogo)!)
        lineModels.append(circleNodeModel)
      }else {
        let circleNodeModel = CircleNodeModel(id: tuple.id, value: tuple.value, icon: UIImage(named: tuple.icon)!, teamLogo: nil)
        lineModels.append(circleNodeModel)
      }
      
    }
    let vm = CircleRankingViewVM(rawDataLineModels: lineModels)
    return vm
  }
  
  func makeTimer() -> Timer {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let duration = dataSource.circleRankingViewRoundDouration(self)
    let timer = Timer.init(timeInterval: duration, target: self, selector: #selector(onTimerFires(sender:)), userInfo: nil, repeats: true)
    return timer
  }
  
  @objc func onTimerFires(sender: Timer) {
    guard let circleNodeModel = viewModel.lineModelsPopLast(), let dataSource = dataSource else {
      invalidateTimer()
      return
    }
    //TODO: - 未來要在這邊把 rank 確定起來
    viewModel.updatePresentedRank(circleNodeModel: circleNodeModel)
    viewModel.presentedRankingNodeView.forEach {
      $0.fireRnakingOrderAnimation()
    }
    
    let foregroundNodeView = makeRankingNodeView(type: .foreground)
    if let _ = viewModel.currentCircleNodeModel?.teamLogo {
      
      let backgroundNodeView = makeRankingNodeView(type: .background)
      addSubview(backgroundNodeView)
      addSubview(foregroundNodeView)
      let width = dataSource.circleRankingViewRankingNodeViewWidth(self)
      foregroundNodeView.anchor(top: nil, bottom: bottomAnchor, leading: leadingAnchor, trailing: nil, padding: .init(top: 0, left: 10, bottom: 20, right: 0), size: .init(width: width, height: width))
      backgroundNodeView.anchor(top: nil, bottom: bottomAnchor, leading: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 20, right: 10), size: .init(width: width, height: width))
      foregroundNodeView.fireAnimation()
      backgroundNodeView.fireAnimation()
    }else {
      addSubview(foregroundNodeView)
      let width = dataSource.circleRankingViewRankingNodeViewWidth(self)
      foregroundNodeView.anchor(top: nil, bottom: bottomAnchor, leading: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 20, right: 0), size: .init(width: width, height: width))
      foregroundNodeView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
      foregroundNodeView.fireAnimation()
    }
    
    
    //這邊要判斷這個 nodeView 是否已經出現過，若已經出現過，則在做完 scaleAndTransation 的動畫要把自己移除。否則就保留，並加入到 presentedLineModels 和 presentedRankingNodeView
    if viewModel.isCurrentLineModelAlreadyExistInPresentedCircleNodeModels {
      viewModel.willRemoveCurrentNodeView()
    }else {
      viewModel.wontRemoveCurrentNodeView()
      viewModel.appendInPresentedCircleNodeModels(circleNodeModel: circleNodeModel)
      viewModel.appendInPresentedRankingNodeViews(rankingNodeView: foregroundNodeView)
    }
  }
  
  public func invalidateTimer() {
    if let _ = timer {
      timer!.invalidate()
    }
    timer = nil
  }
}
