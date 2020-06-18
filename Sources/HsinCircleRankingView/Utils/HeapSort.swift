//
//  HeapSort.swift
//  CircleRankingView
//
//  Created by Chung Han Hsin on 2020/6/6.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import Foundation
//Building a heap from array time is O(nlogn)
//因為每此插入新元素需做siftDown，需要O(logn)的時間
//有n個元素，所以一共為n*logn
struct Heap<Element: Equatable> {
  var elements: [Element] = []
  let sort: (Element, Element) -> Bool
  
  //在initialize heap的時候，會給予>,<來決定此heap為minimize or maximize heap
  //>為max heap
  //<為min heap
  init(sort: @escaping (Element, Element) -> Bool, elements: [Element] = []) {
    self.sort = sort
    self.elements = elements
    
    if !elements.isEmpty{
      //strid(from:從哪個數字開始， to:到哪個數字(不包含)， by:每次要加多少)
      //strid(from:從哪個數字開始， through:到哪個數字(包含)， by:每次要加多少)
      for i in stride(from: elements.count / 2 - 1, through: 0, by: -1){
        //只要依序執行array的前半部，
        //就可以利用sifDown去把整個heap建出來
        //因為所有的child node的 index都可以從parent node推出
        //left childIndex = 2 * parentIndex + 1
        //right childIndex = 2 * parentIndex + 2
        siftDown(from: i)
      }
    }
  }
  
  var isEmpty: Bool{
    return elements.isEmpty
  }
  
  var count: Int{
    return elements.count
  }
  
  func peek() -> Element?{
    return elements.first
  }
  
  //這邊的i就是parent在array中的index
  //而此parent的left child在array中的index為 (2*i) + 1
  //而此parent的right child在array中的index為 (2*i) + 2
  func leftChildIndex(ofParentAt index: Int) -> Int{
    return (2*index) + 1
  }
  
  func rightChildIndex(ofParentAt index: Int) -> Int{
    return (2*index) + 2
  }
  
  func parentIndex(ofChildAt index: Int) -> Int{
    return (index - 1) / 2
  }
}


extension Heap{
  
  //MARK: -Remove root
  
  //Time is O(logn)，因為每次拔掉root，替補heap最後一個element到root，然後往下比大小
  //主要都是執行shifDown的操作，所耗費的時間
  public mutating func remove() -> Element?{
    guard !isEmpty else {return nil}
    
    //因為remove這個動作，每次都會把root移掉(即為此heap中的max or min)
    //所以先把root和此heap中的最後一個元素互相調換位置
    //再把root移掉
    //time is O(1)
    elements.swapAt(0, count - 1)
    defer{
      //調換位置後，開始進行一路比大小的動作
      siftDown(from: 0)
    }
    
    return elements.removeLast()
  }
  
  //Time is O(logn)
  public mutating func siftDown(from index: Int){
    var parent = index
    while true {
      let left = leftChildIndex(ofParentAt: parent)
      let right = rightChildIndex(ofParentAt: parent)
      //此candidate負責追蹤未來誰要與parent做swap
      var candidate = parent
      
      //left < count代表此left child的index在array的範圍內
      //而且也滿足sort的條件(有可能是>or<，端看是minHeap or maxHeap)
      if left < count && sort(elements[left], elements[candidate]){
        //就讓candidate改為left child，未來將與parent swap
        candidate = left
      }
      
      //再去比較右child
      if right < count && sort(elements[right], elements[candidate]){
        candidate = right
      }
      
      //如果candidate沒在變動，即可跳出迴圈
      if candidate == parent{
        return
      }
      
      //parent與candidate互換
      elements.swapAt(parent, candidate)
      //此時的parent變為candidate，再進入while迴圈
      parent = candidate
    }
  }
  
  //for heap sort
  mutating func siftDown(from index: Int, upTo size: Int) {
    var parent = index
    while true {
      let left = leftChildIndex(ofParentAt: parent)
      let right = rightChildIndex(ofParentAt: parent)
      var candidate = parent
      if left < size && sort(elements[left], elements[candidate]) {
        candidate = left
      }
      if right < size && sort(elements[right], elements[candidate]) {
        candidate = right
      }
      if candidate == parent {
        return
      }
      elements.swapAt(parent, candidate)
      parent = candidate
    }
  }
  
  //MARK: -Remove arbitary node
  //Time is O(logn)
  mutating func remove(at index: Int) -> Element?{
    guard index < elements.count else {return nil}
    
    if index == elements.count - 1{
      return elements.removeLast()
    }else{
      elements.swapAt(index, elements.count - 1)
      defer{
        siftDown(from: index)
        siftUp(from: index)
      }
      return elements.removeLast()
    }
  }
  
  //MARK:- Insertion
  //若要插入新elemnet，須從heap的最下層的最後一個node插入(也就是array的最後一個元素)
  //在往上依序跟parent比大小
  //Time is O(logn)
  public mutating func insert(_ element: Element){
    
    //Time is O(1)
    elements.append(element)
    //Time is O(logn)
    siftUp(from: elements.count - 1)
  }
  
  //Time is O(logn)
  public mutating func siftUp(from index: Int){
    var child = index
    var parent = parentIndex(ofChildAt: child)
    while child > 0 && sort(elements[child], elements[parent]) {
      elements.swapAt(child, parent)
      child = parent
      parent = parentIndex(ofChildAt: child)
    }
  }
  
  //MARK:- Searching
  //Time is O(n)，因為是用array去實作的，所以worst case會是linear search
  func index(of element: Element, startingAt i: Int) -> Int?{
    //i 超出bounds
    if i >= count{
      return nil
    }
    
    //如果此元素就已經>或< heap的root
    //代表此heap必定無此元素
    // 因為heap的root，即為此heap的max or min
    if sort(element, elements[i]){
      return nil
    }
    
    //找到元素拉
    if element == elements[i]{
      return i
    }
    
    //遞迴去尋找看此元素有沒有在left child's subtree
    if let j = index(of: element, startingAt: leftChildIndex(ofParentAt: i)){
      return j
    }
    
    //遞迴去尋找看此元素有沒有在right child's subtree
    if let j = index(of: element, startingAt: rightChildIndex(ofParentAt: i)){
      return j
    }
    
    return nil
  }
  
}



//與selection sort相似
//先傳進一個Max heap，因為max值一定在root，
//所以每次都先將root和最後一個node swap
//在做siftDown，使新的root滿足heap的規則
//在重新做上述步驟
//但須將每一回合被swap的root排除在重構heap的動作

//Time is O(nLogn)
//每一次swap root後，都需要做siftDown的動作，重構heap
//有n個node要走過，所以一共為nlogn
extension Heap{
  func heapSorted() -> [Element]{
    var heap = Heap.init(sort: sort, elements: elements)
    for index in heap.elements.indices.reversed(){
      heap.elements.swapAt(0, index)
      heap.siftDown(from: 0, upTo: index)
    }
    return heap.elements
  }
}
