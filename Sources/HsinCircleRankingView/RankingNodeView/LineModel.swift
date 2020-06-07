//
//  DataModel.swift
//  ScrollViewTest
//
//  Created by Chung Han Hsin on 2020/5/16.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit

public class LineModel {
  
  private(set) var id: String
  private(set) var value: Float
  private(set) var rank: Int = 999
  private(set) var icon: UIImage
  
  init(id: String, value: Float, icon: UIImage) {
    self.id = id
    self.value = value
    self.icon = icon
  }
  
  func setRank(_ rank: Int) {
    self.rank = rank
  }
}

extension LineModel: Comparable {
  public static func == (lhs: LineModel, rhs: LineModel) -> Bool {
    if lhs.value == rhs.value {
      return true
    }
    return false
  }
  
  public static func < (lhs: LineModel, rhs: LineModel) -> Bool {
    if lhs.value < rhs.value {
      return true
    }
    return false
  }
}

