//
//  APIRouter.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 14.12.2020.
//

import Foundation
import Alamofire

enum APIRouter {
    case getNews(queryText: String, page: Int, date: String)
}

extension APIRouter: URLRequestConvertible {
    static let baseURLString = "http://newsapi.org/v2/"
    static let apiKey = "3e57b271c98d4af3ba91cc32d82faa69"

    var method: HTTPMethod {
        switch self {
        case .getNews:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getNews:
            return "everything"
        }
    }

    var body: Parameters {
        switch self {
        case .getNews(let queryText, let page, let date):
            return ["q": queryText,
                    "sortBy": "publishedAt",
                    "page": page,
                    "apiKey": APIRouter.apiKey,
                    "pageSize": 10,
                    "to": date
            ]
        }
    }

    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try APIRouter.baseURLString.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest = try URLEncoding.default.encode(urlRequest, with: body)
        print(urlRequest)
        return urlRequest
    }
}
