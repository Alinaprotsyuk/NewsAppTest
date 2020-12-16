//
//  BehaviorRelay+remove.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 16.12.2020.
//

import Foundation
import RxCocoa

extension BehaviorRelay where Element: RangeReplaceableCollection {
    func append(_ subElement: Element.Element) {
        var newValue = value
        newValue.append(subElement)
        accept(newValue)
    }
    
    func append(contentsOf: [Element.Element]) {
        var newValue = value
        newValue.append(contentsOf: contentsOf)
        accept(newValue)
    }
    
    func remove(at index: Element.Index) {
        var newValue = value
        newValue.remove(at: index)
        accept(newValue)
    }
    
    func removeAll() {
        var newValue = value
        newValue.removeAll()
        accept(newValue)
    }
}
