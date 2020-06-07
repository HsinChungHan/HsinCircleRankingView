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
  private(set)var rawDataLineModels: [LineModel]
  private(set) var presentedLineModels = [LineModel]()
  private(set) var presentedRankingNodeView = [RankingNodeView]()
  private(set) var currentLineModel: LineModel?
  
  private(set) var isRemovedCurrentNodeView: Bool = false
  
  var isCurrentLineModelAlreadyExistInPresentedLineModels: Bool {
    if let currentLineModel = currentLineModel {
      for lineModel in presentedLineModels {
        if lineModel.id == currentLineModel.id {
          return true
        }
      }
    }
    return false
  }
  
  var currentPresentedLineModel: LineModel? {
    if let currentLineModel = currentLineModel {
      for model in presentedLineModels {
        if currentLineModel.id == model.id {
          return model
        }
      }
    }
    return nil
  }
  
  var currentPresentedRankingNodeView: RankingNodeView? {
    if let currentLineModel = currentLineModel {
      for view in presentedRankingNodeView {
        if view.viewModel.id == currentLineModel.id {
          return view
        }
      }
    }
    return nil
  }
  
  init(rawDataLineModels: [LineModel]) {
    self.rawDataLineModels = rawDataLineModels
  }
  
  //MARK: - Intrnal functions
  func lineModelsPopLast() -> LineModel? {
    guard let lineModel = rawDataLineModels.popLast() else {
      return nil
    }
    currentLineModel = lineModel
    return lineModel
  }
  
  func appendInPresentedLineModels(lineModel: LineModel) {
    presentedLineModels.append(lineModel)
  }
  
  func appendInPresentedRankingNodeViews(rankingNodeView: RankingNodeView) {
    presentedRankingNodeView.append(rankingNodeView)
  }
  
  func updatePresentedRank(currentLineModel: LineModel) {
    
    var newPresentedLineModels: [LineModel]
    
    //若 currentPresentedRankingNodeView 前面已經出現過了，就去更新 presentedLineModels 和 presentedRankingNodeView 所儲存的 lineModel
    if isCurrentLineModelAlreadyExistInPresentedLineModels {
      for (index, model) in presentedLineModels.enumerated() {
        if model.id == currentLineModel.id {
          presentedLineModels[index] = currentLineModel
          presentedRankingNodeView[index].viewModel.setLineModel(currentLineModel)
          break
        }
      }
      newPresentedLineModels = presentedLineModels
    }else {
      newPresentedLineModels = presentedLineModels
      newPresentedLineModels.append(currentLineModel)
    }
    
    //找到排序過後的 PresentedLineModels
    let sortedNewPresentedLineModels = Heap(sort: <, elements: newPresentedLineModels).heapSorted()
    //將排序過後的 PresentedLineModels，利用 index 更新成新的 rank
    for (index, _) in sortedNewPresentedLineModels.enumerated() {
      sortedNewPresentedLineModels[index].setRank(index)
    }
    
    //最後去更新 currentLineModel, presentedLineModels, presentedRankingNodeView 的 rank
    for (newModelIndex, newModel) in sortedNewPresentedLineModels.enumerated() {
      if newModel.id == currentLineModel.id {
        self.currentLineModel?.setRank(newModelIndex)
      }
      
      for (modelIndex, model) in presentedLineModels.enumerated() {
        if model.id == newModel.id {
          presentedLineModels[modelIndex].setRank(newModel.rank)
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
