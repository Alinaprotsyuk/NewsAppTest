//
//  PaginationModel.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 15.12.2020.
//

import Foundation

struct PaginationModel {
    var page = 1
    var totalPages: Int? = nil
    var dataCount = 0
    
    var nextPage: Int? {
        guard let total = totalPages else { return nil }
        let nextPage = page + 1
        guard nextPage < total else { return nil }
        return nextPage
    }
    
    mutating func setupInitialValues() {
        page = 1
        totalPages = nil
        dataCount = 0
    }
}
