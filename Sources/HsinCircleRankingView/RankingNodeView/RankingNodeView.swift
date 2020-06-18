//
//  RankingNodeView.swift
//  CircleRankingView
//
//  Created by Chung Han Hsin on 2020/6/4.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit
import HsinUtils

public enum ImageLayerType {
  case icon
  case team
}

public enum NodeType: String {
  case foreground = "foreground"
  case background = "background"
}

//MARK: - RankingNodeViewDataSource

protocol RankingNodeViewDataSource: AnyObject {
  
  func rankingNodeViewCircleRankingViewNumberOfItemsInRows(_ rankingNodeView: RankingNodeView) -> Int
  func rankingNodeViewWidth(_ rankingNodeView: RankingNodeView) -> CGFloat
  func rankingNodeViewOpacityDuration(_ rankingNodeView: RankingNodeView) -> TimeInterval
  func rankingNodeViewXTransationToCircleRankingViewMidXDuration(_ rankingNodeView: RankingNodeView) -> TimeInterval
  func rankingNodeViewTotalDuration(_ rankingNodeView: RankingNodeView) -> TimeInterval
  func rankingNodeViewScale(_ rankingNodeView: RankingNodeView) -> CGFloat
  func rankingNodeViewCircleNodelModel(_ rankingNodeView: RankingNodeView) -> CircleNodeModel
  func rankingNodeViewMidX(_ rankingNodeView: RankingNodeView) -> CGFloat
  func rankingNodeViewMidY(_ rankingNodeView: RankingNodeView) -> CGFloat
  func rankingNodeViewPadding(_ rankingNodeView: RankingNodeView) -> CGFloat
  func rankingNodeViewCirecleRankingViewMidX(_ rankingNodeView: RankingNodeView) -> CGFloat
  func rankingNodeViewBackgroundColor(_ rankingNodeView: RankingNodeView) -> UIColor
}

//MARK: - RankingNodeViewDelegate

protocol RankingNodeViewDelegate: AnyObject {
  
  func rankingNodeViewOpacityGroupDidStop(_ rankingNodeView: RankingNodeView, anim: CAAnimation)
  func rankingNodeViewXTransationGroupDidStop(_ rankingNodeView: RankingNodeView, anim: CAAnimation)
  func rankingNodeViewScaleAndTransationAnimationGroupDidStop(_ rankingNodeView: RankingNodeView, anim: CAAnimation)
  func rankingNodeViewTransationAnimationGroupDidStop(_ rankingNodeView: RankingNodeView, anim: CAAnimation)
}

//MARK: - RankingNodeView
class RankingNodeView: UIView {
  
  weak var dataSource: RankingNodeViewDataSource?
  weak var delegate: RankingNodeViewDelegate?
  lazy var foregroundImageLayer = makeImageLayer(type: .icon)
  lazy var backgroundImageLayer = makeImageLayer(type: .team)
  lazy var overallLayer = makeOverallLayer()
  lazy var viewModel = makeViewModel()
  
  let nodeType: NodeType
  
  init(nodeType: NodeType) {
    self.nodeType = nodeType
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: - View lifeCycle
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let width = dataSource.rankingNodeViewWidth(self)
    [backgroundImageLayer, foregroundImageLayer].forEach {
      $0.frame = CGRect(x: 0, y: 0, width: width, height: width)
    }
    backgroundImageLayer.isHidden = true
    overallLayer.frame = CGRect(x: 0, y: 0, width: width, height: width)
    layer.addSublayer(overallLayer)
  }
}


//MARK: - Private functions

extension RankingNodeView {
  fileprivate func makeOverallLayer() -> CALayer {
    let layer = CALayer()
    [backgroundImageLayer, foregroundImageLayer].forEach {
      layer.addSublayer($0)
    }
    return layer
  }
  
  fileprivate func makeImageLayer(type: ImageLayerType) -> CALayer {
    let layer = CALayer()
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let width = dataSource.rankingNodeViewWidth(self)
    let backgroundColor = dataSource.rankingNodeViewBackgroundColor(self).cgColor
    
    switch nodeType {
      case .foreground:
        layer.contents = viewModel.icon.cgImage
        layer.contentsGravity = .resizeAspect
      case .background:
        layer.contents = viewModel.teamLogo?.cgImage
        layer.contentsGravity = .resizeAspect
        layer.backgroundColor = backgroundColor
    }
    
    switch type {
      case .icon:
        break
      case .team:
        layer.contents = viewModel.teamLogo?.cgImage
        layer.contentsGravity = .resizeAspect
    }
    layoutIfNeeded()
    //    layer.backgroundColor = UIColor.clear.cgColor
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
    let circleNodelModel = dataSource.rankingNodeViewCircleNodelModel(self)
    let width = dataSource.rankingNodeViewWidth(self)
    let scale = dataSource.rankingNodeViewScale(self)
    let numberOfItems = dataSource.rankingNodeViewCircleRankingViewNumberOfItemsInRows(self)
    //TODO: - 之後要從外面傳進一個 property 來判斷是否有 background node view
    let xFromValue = dataSource.rankingNodeViewMidX(self)
    let yFromValue = dataSource.rankingNodeViewMidY(self)
    let padding = dataSource.rankingNodeViewPadding(self)
    let vm = RankingNodeViewVM(circleNodelModel: circleNodelModel, numberOfItems: numberOfItems, scaleWidth: width * scale, xFromValue: xFromValue, yFromValue: yFromValue, padding: padding)
    return vm
  }
}

//MARK: - Public functions

extension RankingNodeView {
  
  func fireAnimation() {
    doOpacityAnimation()
  }
  
  func fireRnakingOrderAnimation() {
    doXYTransationAnimation()
  }
  
  fileprivate func doOpacityAnimation() {
    let animationGroup = makeOpacityAnimationGroup()
    overallLayer.add(animationGroup, forKey: "opacityAnimation")
  }
  
  fileprivate func doXYTransationAnimation() {
    //layer.removeAllAnimations()
    let animationGroup = makeXYTransationGroup()
    overallLayer.add(animationGroup, forKey: "transationAnimationGroup")
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
  
  fileprivate func makeXTransationGroup() -> CAAnimationGroup {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let xFromValue = dataSource.rankingNodeViewMidX(self)
    let destX = dataSource.rankingNodeViewCirecleRankingViewMidX(self)
    let convertedOriginPoint = convert(CGPoint(x: 0, y: 0), to: superview)
    let xToValue = destX - convertedOriginPoint.x
    viewModel.updateXFromValue(fromValue: xToValue)
    let duration = dataSource.rankingNodeViewXTransationToCircleRankingViewMidXDuration(self)
    let animation = makeXTransation(fromValue: xFromValue, toValue: xToValue)
    let group = makeGroupAnimation(groupId: "\(nodeType.rawValue)XTransationGroup", duration: duration, animations: animation)
    return group
  }
  
  fileprivate func makeOpacityAnimationGroup() -> CAAnimationGroup {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let opacityDuration = dataSource.rankingNodeViewOpacityDuration(self)
    let animation = makeOpacityAnimation()
    let group = makeGroupAnimation(groupId: "\(nodeType.rawValue)OpacityGroup", duration: opacityDuration, animations: animation)
    return group
  }
  
  //用在一開始到正確排序位置時
  fileprivate func makeScaleAndXYTransationAnimationGroup() -> CAAnimationGroup {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let scale = dataSource.rankingNodeViewScale(self)
    let totalDuration = dataSource.rankingNodeViewTotalDuration(self)
    let opacityDuration = dataSource.rankingNodeViewOpacityDuration(self)
    let xTransationDuration = dataSource.rankingNodeViewXTransationToCircleRankingViewMidXDuration(self)
    let animationDuration = totalDuration - opacityDuration - xTransationDuration
    let convertedOriginPoint = convert(CGPoint(x: 0, y: 0), to: superview)
    let xTransation = makeXTransation(fromValue: viewModel.xRankingOrderFromValue, toValue: viewModel.xRankingOrderToValue - convertedOriginPoint.x)
    let yTransation = makeYTransation(fromValue: viewModel.yRankingOrderFromValue, toValue: viewModel.yRankingOrderToValue - convertedOriginPoint.y)
    viewModel.updateXYFromValue()
    let scaleAnimation = makeScaleAnimation(toValue: scale)
    let group = makeGroupAnimation(groupId: "\(nodeType.rawValue)ScaleAndTransationGroup", duration: animationDuration, animations: xTransation, yTransation, scaleAnimation)
    return group
  }
  
  //用在後來排名有變動時的排序
  fileprivate func makeXYTransationGroup() -> CAAnimationGroup {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set dataSource for RankingNodeView first")
    }
    let totalDuration = dataSource.rankingNodeViewTotalDuration(self)
    let opacityDuration = dataSource.rankingNodeViewOpacityDuration(self)
    let xTransationDuration = dataSource.rankingNodeViewXTransationToCircleRankingViewMidXDuration(self)
    let animationDuration = totalDuration - opacityDuration - xTransationDuration
    let convertedOriginPoint = convert(CGPoint(x: 0, y: 0), to: superview)
    let xTransation = makeXTransation(fromValue: viewModel.xRankingOrderFromValue - convertedOriginPoint.x, toValue: viewModel.xRankingOrderToValue - convertedOriginPoint.x)
    let yTransation = makeYTransation(fromValue: viewModel.yRankingOrderFromValue - convertedOriginPoint.y, toValue: viewModel.yRankingOrderToValue - convertedOriginPoint.y)
    viewModel.updateXYFromValue()
    let group = makeGroupAnimation(groupId: "\(nodeType.rawValue)XYTransationGroup", duration: animationDuration, animations: xTransation, yTransation)
    return group
  }
}

//MARK: - CAAnimationDelegate

extension RankingNodeView: CAAnimationDelegate {
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    let groupId = anim.value(forKey: "groupId") as! String
    print("groupId: \(groupId)")
    if groupId == "\(nodeType.rawValue)OpacityGroup" {
      //TODO: - 未來應該要從外面傳入是否有 background node view 的存在
      //yes => 做 makeXTransationGroup() 的動畫
      //no => 直接做 makeScaleAndXYTransationAnimationGroup() 的動畫
      if let _ = viewModel.teamLogo {
        let animationGroup = makeXTransationGroup()
        overallLayer.add(animationGroup, forKey: "animationGroup")
        
        delegate?.rankingNodeViewXTransationGroupDidStop(self, anim: anim)
      }else {
        let animationGroup = makeScaleAndXYTransationAnimationGroup()
        overallLayer.add(animationGroup, forKey: "animationGroup")
        delegate?.rankingNodeViewOpacityGroupDidStop(self, anim: anim)
      }
    }
    
    
    if groupId == "\(nodeType.rawValue)XTransationGroup" {
      guard let dataSource = dataSource else {
        fatalError("🚨 You have to set dataSource for RankingNodeView first")
      }
      let backgroundColor = dataSource.rankingNodeViewBackgroundColor(self).cgColor
      if nodeType == .foreground {
        backgroundImageLayer.isHidden = false
        backgroundImageLayer.backgroundColor = backgroundColor
      }
      
      let animationGroup = makeScaleAndXYTransationAnimationGroup()
      overallLayer.add(animationGroup, forKey: "animationGroup")
      delegate?.rankingNodeViewOpacityGroupDidStop(self, anim: anim)
    }
    
    if groupId == "\(nodeType.rawValue)ScaleAndTransationGroup" {
      if nodeType == .background {
        removeFromSuperview()
        layer.removeFromSuperlayer()
      }
		delegate?.rankingNodeViewScaleAndTransationAnimationGroupDidStop(self, anim: anim)
    }
    
    if groupId == "\(nodeType.rawValue)XYTransationGroup" {
      
      delegate?.rankingNodeViewTransationAnimationGroupDidStop(self, anim: anim)
    }
  }
}
