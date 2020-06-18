//
//  RankingNodeView.swift
//  CircleRankingView
//
//  Created by Chung Han Hsin on 2020/6/4.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit
import HsinUtils

//MARK: - RankingNodeViewDataSource

protocol RankingNodeViewDataSource: AnyObject {
  
  func rankingNodeViewCircleRankingViewNumberOfItemsInRows(_ rankingNodeView: RankingNodeView) -> Int
  func rankingNodeViewWidth(_ rankingNodeView: RankingNodeView) -> CGFloat
  func rankingNodeViewOpacityDuration(_ rankingNodeView: RankingNodeView) -> TimeInterval
  func rankingNodeViewTotalDuration(_ rankingNodeView: RankingNodeView) -> TimeInterval
  func rankingNodeViewScale(_ rankingNodeView: RankingNodeView) -> CGFloat
  func rankingNodeViewLineModel(_ rankingNodeView: RankingNodeView) -> LineModel
  func rankingNodeViewMidX(_ rankingNodeView: RankingNodeView) -> CGFloat
  func rankingNodeViewMidY(_ rankingNodeView: RankingNodeView) -> CGFloat
  func rankingNodeViewPadding(_ rankingNodeView: RankingNodeView) -> CGFloat
}

//MARK: - RankingNodeViewDelegate

protocol RankingNodeViewDelegate: AnyObject {
  
  func rankingNodeViewOpacityGroupDidStop(_ rankingNodeView: RankingNodeView, anim: CAAnimation)
  func rankingNodeViewScaleAndTransationAnimationGroupDidStop(_ rankingNodeView: RankingNodeView, anim: CAAnimation)
  func rankingNodeViewTransationAnimationGroupDidStop(_ rankingNodeView: RankingNodeView, anim: CAAnimation)
}

//MARK: - RankingNodeView
class RankingNodeView: UIView {

  weak var dataSource: RankingNodeViewDataSource?
  weak var delegate: RankingNodeViewDelegate?
  lazy var imageLayer = makeImageLayer()
  lazy var backgroundImageLayer = makeImageLayer()
  lazy var viewModel = makeViewModel()
  
  //MARK: - View lifeCycle
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let width = dataSource.rankingNodeViewWidth(self)
    [backgroundImageLayer].forEach {
      layer.addSublayer($0)
      layer.backgroundColor = UIColor.clear.cgColor
      $0.frame = CGRect(x: 0, y: 0, width: width, height: width)
    }
  }
}


//MARK: - Private functions

extension RankingNodeView {
  
  fileprivate func makeImageLayer() -> CALayer {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let width = dataSource.rankingNodeViewWidth(self)
    let icon = viewModel.icon
    let layer = CALayer()
    layer.contents = icon.cgImage
    layoutIfNeeded()
    layer.contentsGravity = .resizeAspect
    layer.backgroundColor = UIColor.clear.cgColor
    layer.isGeometryFlipped = true
    layer.borderColor = UIColor.white.cgColor
    layer.borderWidth = 5.0
    layer.cornerRadius = width / 2
    layer.masksToBounds = true
    return layer
  }
  
  fileprivate func makeBackgroundImageLayer() -> CALayer {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let width = dataSource.rankingNodeViewWidth(self)
    let teamLogo = viewModel.teamLogo
    let layer = CALayer()
    layer.contents = teamLogo?.cgImage
    layoutIfNeeded()
    layer.contentsGravity = .resizeAspect
    layer.isGeometryFlipped = true
    layer.borderColor = UIColor.white.cgColor
    layer.borderWidth = 5.0
    layer.cornerRadius = width / 2
    layer.masksToBounds = true
    return layer
  }
  
  fileprivate func makeViewModel() -> RankingNodeViewVM {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let lineModel = dataSource.rankingNodeViewLineModel(self)
    let width = dataSource.rankingNodeViewWidth(self)
    let scale = dataSource.rankingNodeViewScale(self)
    let numberOfItems = dataSource.rankingNodeViewCircleRankingViewNumberOfItemsInRows(self)
    let xFromValue = dataSource.rankingNodeViewMidX(self)
    let yFromValue = dataSource.rankingNodeViewMidY(self)
    let padding = dataSource.rankingNodeViewPadding(self)
    let vm = RankingNodeViewVM(lineModel: lineModel, numberOfItems: numberOfItems, scaleWidth: width * scale, xFromValue: xFromValue, yFromValue: yFromValue, padding: padding)
    return vm
  }
}

//MARK: - Public functions

extension RankingNodeView {
  
  func doOpacityAnimation() {
    let animation = makeOpacityAnimationGroup()
    [backgroundImageLayer, imageLayer].forEach {
    	$0.add(animation, forKey: "opacityAnimation")
    }
  }
  
  func doTransationAnimation() {
    //layer.removeAllAnimations()
    let animation = makeTransationGroup()
    [backgroundImageLayer, imageLayer].forEach {
      $0.add(animation, forKey: "transationAnimationGroup")
    }
  }
}

//MARK: - Animation

extension RankingNodeView {
  
  fileprivate func makeOpacityAnimation() -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: "opacity")
    animation.fromValue = 0.0
    animation.toValue = 1.0
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    return animation
  }
  
  fileprivate func makeXTransation(fromValue: CGFloat, toValue: CGFloat) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: "position.x")
    animation.fromValue = fromValue
    animation.toValue = toValue
    return animation
  }
  
  fileprivate func makeYTransation(fromValue: CGFloat, toValue: CGFloat) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: "position.y")
    animation.fromValue = fromValue
    animation.toValue = toValue
    return animation
  }
  
  fileprivate func makeScaleAnimation(toValue: CGFloat) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.fromValue = 1.0
    animation.toValue = toValue
    return animation
  }
  
  fileprivate func makeGroupAnimation(groupId: String, duration: TimeInterval, animations: CAAnimation...) -> CAAnimationGroup {
    let group = CAAnimationGroup()
    group.animations = animations
    group.duration = duration
    //    group.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
    group.fillMode = .forwards
    group.isRemovedOnCompletion = false
    group.delegate = self
    group.setValue(groupId, forKey: "groupId")
    return group
  }
  
  fileprivate func makeOpacityAnimationGroup() -> CAAnimationGroup {
    guard let dataSource = dataSource else {
         fatalError("🚨 You have to set dataSource for RankingNodeView first")
       }
    let opacityDuration = dataSource.rankingNodeViewOpacityDuration(self)
    let animation = makeOpacityAnimation()
    let group = makeGroupAnimation(groupId: "OpacityGroup", duration: opacityDuration, animations: animation)
    return group
  }
  
  fileprivate func makeScaleAndTransationAnimationGroup() -> CAAnimationGroup {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let scale = dataSource.rankingNodeViewScale(self)
    let totalDuration = dataSource.rankingNodeViewTotalDuration(self)
    let opacityDuration = dataSource.rankingNodeViewOpacityDuration(self)
    let animationDuration = totalDuration - opacityDuration
    let convertedOriginPoint = convert(CGPoint(x: 0, y: 0), to: superview)
    let xTransation = makeXTransation(fromValue: viewModel.xFromValue, toValue: viewModel.xToValue - convertedOriginPoint.x)
    let yTransation = makeYTransation(fromValue: viewModel.yFromValue, toValue: viewModel.yToValue - convertedOriginPoint.y)
    viewModel.updateXYFromValue()
    let scaleAnimation = makeScaleAnimation(toValue: scale)
    let group = makeGroupAnimation(groupId: "ScaleAndTransationGroup", duration: animationDuration, animations: xTransation, yTransation, scaleAnimation)
    return group
  }
  
  fileprivate func makeTransationGroup() -> CAAnimationGroup {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let totalDuration = dataSource.rankingNodeViewTotalDuration(self)
    let opacityDuration = dataSource.rankingNodeViewOpacityDuration(self)
    let animationDuration = totalDuration - opacityDuration
    let convertedOriginPoint = convert(CGPoint(x: 0, y: 0), to: superview)
    let xTransation = makeXTransation(fromValue: viewModel.xFromValue - convertedOriginPoint.x, toValue: viewModel.xToValue - convertedOriginPoint.x)
    let yTransation = makeYTransation(fromValue: viewModel.yFromValue - convertedOriginPoint.y, toValue: viewModel.yToValue - convertedOriginPoint.y)
    viewModel.updateXYFromValue()
    let group = makeGroupAnimation(groupId: "TransationGroup", duration: animationDuration, animations: xTransation, yTransation)
    return group
  }
}

//MARK: - CAAnimationDelegate

extension RankingNodeView: CAAnimationDelegate {
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    let groupId = anim.value(forKey: "groupId") as! String
    
    if groupId == "OpacityGroup" {
      let animationGroup = makeScaleAndTransationAnimationGroup()
      [backgroundImageLayer, imageLayer].forEach {
        $0.add(animationGroup, forKey: "animationGroup")
      }
      delegate?.rankingNodeViewOpacityGroupDidStop(self, anim: anim)
    }
    
    if groupId == "ScaleAndTransationGroup" {
      delegate?.rankingNodeViewScaleAndTransationAnimationGroupDidStop(self, anim: anim)
    }
    
    if groupId == "TransationGroup" {
      delegate?.rankingNodeViewTransationAnimationGroupDidStop(self, anim: anim)
    }
  }
}
