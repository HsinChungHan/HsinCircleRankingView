//
//  CircleRankingViewVM.swift
//  CircleRankingView
//
//  Created by Chung Han Hsin on 2020/6/4.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import Foundation

class CircleRankingViewVM {
  //MARK: - Properties
  private(set)var rawDataCircleNodeModels: [CircleNodeModel]
  private(set) var presentedCircleNodeModels = [CircleNodeModel]()
  private(set) var presentedRankingNodeView = [RankingNodeView]()
  private(set) var currentCircleNodeModel: CircleNodeModel?
  
  private(set) var isRemovedCurrentNodeView: Bool = false
  
  var isCurrentLineModelAlreadyExistInPresentedCircleNodeModels: Bool {
    if let currentCircleNodeModel = currentCircleNodeModel {
      for circleNodeModel in presentedCircleNodeModels {
        if circleNodeModel.id == currentCircleNodeModel.id {
          return true
        }
      }
    }
    return false
  }
  
  var currentPresentedCircleNodeModel: CircleNodeModel? {
    if let currentCircleNodeModel = currentCircleNodeModel {
      for model in presentedCircleNodeModels {
        if currentCircleNodeModel.id == model.id {
          return model
        }
      }
    }
    return nil
  }
  
  var currentPresentedRankingNodeView: RankingNodeView? {
    if let currentCircleNodeModel = currentCircleNodeModel {
      for view in presentedRankingNodeView {
        if view.viewModel.id == currentCircleNodeModel.id {
          return view
        }
      }
    }
    return nil
  }
  
  init(rawDataLineModels: [CircleNodeModel]) {
    self.rawDataCircleNodeModels = rawDataLineModels
  }
  
  //MARK: - Intrnal functions
  func lineModelsPopLast() -> CircleNodeModel? {
    guard let circleNodeModel = rawDataCircleNodeModels.popLast() else {
      return nil
    }
    currentCircleNodeModel = circleNodeModel
    return circleNodeModel
  }
  
  func appendInPresentedCircleNodeModels(circleNodeModel: CircleNodeModel) {
    presentedCircleNodeModels.append(circleNodeModel)
  }
  
  func appendInPresentedRankingNodeViews(rankingNodeView: RankingNodeView) {
    presentedRankingNodeView.append(rankingNodeView)
  }
  
  func updatePresentedRank(circleNodeModel: CircleNodeModel) {
    
    var newPresentedCircleNodeModels: [CircleNodeModel]
    
    //若 currentPresentedRankingNodeView 前面已經出現過了，就去更新 presentedLineModels 和 presentedRankingNodeView 所儲存的 lineModel
    if isCurrentLineModelAlreadyExistInPresentedCircleNodeModels {
      for (index, model) in presentedCircleNodeModels.enumerated() {
        if model.id == circleNodeModel.id {
          presentedCircleNodeModels[index] = circleNodeModel
          presentedRankingNodeView[index].viewModel.setLineModel(circleNodeModel)
          break
        }
      }
      newPresentedCircleNodeModels = presentedCircleNodeModels
    }else {
      newPresentedCircleNodeModels = presentedCircleNodeModels
      newPresentedCircleNodeModels.append(circleNodeModel)
    }
    
    //找到排序過後的 PresentedLineModels
    let sortedNewPresentedLineModels = Heap(sort: <, elements: newPresentedCircleNodeModels).heapSorted()
    //將排序過後的 PresentedLineModels，利用 index 更新成新的 rank
    for (index, _) in sortedNewPresentedLineModels.enumerated() {
      sortedNewPresentedLineModels[index].setRank(index)
    }
    
    //最後去更新 currentLineModel, presentedLineModels, presentedRankingNodeView 的 rank
    for (newModelIndex, newModel) in sortedNewPresentedLineModels.enumerated() {
      if newModel.id == circleNodeModel.id {
        self.currentCircleNodeModel?.setRank(newModelIndex)
      }
      
      for (modelIndex, model) in presentedCircleNodeModels.enumerated() {
        if model.id == newModel.id {
          presentedCircleNodeModels[modelIndex].setRank(newModel.rank)
          presentedRankingNodeView[modelIndex].viewModel.setRank(newModel.rank)
          break
        }
      }
    }
  }
  
  func willRemoveCurrentNodeView() {
    isRemovedCurrentNodeView = true
  }
  
  func wontRemoveCurrentNodeView() {
    isRemovedCurrentNodeView = false
  }
}
