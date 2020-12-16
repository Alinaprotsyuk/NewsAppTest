//
//  APIClient.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 14.12.2020.
//

import Foundation
import Alamofire
import RxSwift

class APIClient {
    let session: Session
    let decoder: JSONDecoder

    init(session: Session = Session.default) {
        self.session = session
        decoder = JSONDecoder()
    }

    @discardableResult
    func performRequest<T: Decodable>(request: URLRequestConvertible,
                                      completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest {
        session.request(request).responseDecodable(decoder: decoder) { (response) in
            completion(response.result)
        }
    }
    
    func perform<T: Decodable>(request: URLRequestConvertible) -> Observable<T>? {
        return Observable<T>.create({ observer in
            self.session.request(request).response { response in
                guard let responseData =  response.data else {
                    if let error = response.error {
                        observer.onError(error)
                    }
                    return observer.onCompleted()
                }
                do {
                    let model = try JSONDecoder().decode(T.self, from: responseData)
                    observer.onNext(model)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                    observer.onCompleted()
                }
            }
               return Disposables.create()
           })
    }
}

//MARK: - APIClientView
extension APIClient: APIClientView {
    func getNews(with queryText: String, from page: Int, and date: String) -> Observable<NewsDataModel>? {
        return perform(request: APIRouter.getNews(queryText: queryText, page: page, date: date))
    }
}
