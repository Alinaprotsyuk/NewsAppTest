//
//  SectionOfArticles.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 15.12.2020.
//

import Foundation
import RxDataSources

struct SectionOfArticles {
    var header: String
    var items: [Item]
    
    mutating func remove(at index: Int) {
        items.remove(at: index)
    }
}

//MARK: - SectionModelType
extension SectionOfArticles: SectionModelType {
    typealias Item = Article
    
    init(original: SectionOfArticles, items: [Item]) {
        self = original
        self.items = items
    }
}
