//
//  APIClientView.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 14.12.2020.
//

import Foundation
import Alamofire
import RxSwift

protocol APIClientView {
    func getNews(with queryText: String, from page: Int, and date: String) -> Observable<NewsDataModel>?
}
