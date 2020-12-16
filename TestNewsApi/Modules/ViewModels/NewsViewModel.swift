//
//  NewsViewModel.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 14.12.2020.
//

import Foundation
import RxSwift
import RxCocoa

class NewsViewModel {
    var newsData: NewsDataModel?
    var articlesSection: BehaviorRelay<[SectionOfArticles]> = BehaviorRelay(value: [])
    var networkService: APIClientView?
    
    var isLoadingData = false
    let fromDate: String
    var paginationModel = PaginationModel()
    let disposeBag = DisposeBag()
    var hideRefreshControl = PublishRelay<Bool>()
    var errorMessage: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    var queue = DispatchQueue(label: "ua.com.ap.TestNewsApi")
    
    init() {
        networkService = DIContainer.resolve(service: APIClient.self, name: DIContainer.ContainerKeys.apiClient.rawValue)
        fromDate = Date().dayStringDate
    }
    
    func getNews(from searchText: String, page: Int) {
        guard !searchText.isEmpty,
              !isLoadingData else {
            hideRefreshControl.accept(true)
            articlesSection.removeAll()
            return
        }
        
        if page == 1 {
            paginationModel.setupInitialValues()
        }
        
        queue.async { [unowned self] in
            getNewsData(with: searchText, in: page)
        }
    }
    
    func removeItem(at indexPath: IndexPath) {
        var newValue = articlesSection.value
        newValue[indexPath.section].remove(at: indexPath.row)
        
        if newValue[indexPath.section].items.isEmpty {
            newValue.remove(at: indexPath.section)
        }
        
        articlesSection.accept(newValue)
    }
    
    //MARK: - Private functions
    private func getNewsData(with searchText: String, in page: Int) {
        isLoadingData = true
        networkService?.getNews(with: searchText, from: page, and: fromDate)?
            .subscribeOn(MainScheduler.instance)
            .map({ [unowned self] (model)  -> [Article] in
                self.paginationModel.totalPages = (model.totalResults ?? 0 / 10)
                self.paginationModel.dataCount += model.articles?.count ?? 0
                self.paginationModel.page = page
                return model.articles ?? []
            })
            .compactMap({ articleArray in
                return articleArray.compactMap({ ($0.publishedAt?.toDate()?.dayStringDate ?? "", $0) })
            })
            .subscribe(onNext: { [unowned self] (model) in
                self.hideRefreshControl.accept(true)
                
                if page == 1 {
                    self.articlesSection.accept(self.convertDataToDataSourceModel(model))
                } else {
                    var value = self.articlesSection.value
                    var newDataModel = self.convertDataToDataSourceModel(model)
                    
                    if let indexNewData = self.index(of: newDataModel.first?.header ?? ""),
                       let indexOfOldData = self.index(of: newDataModel.first?.header ?? "") {
                        newDataModel[indexOfOldData].items.forEach { (article) in
                            value[indexNewData].items.append(article)
                        }
                        
                        newDataModel.removeFirst()
                    }
                    value = value + newDataModel
                    self.articlesSection.accept(value)
                    
                }
                self.isLoadingData = false
            }, onError: { [unowned self] (error) in
                self.errorMessage.accept(error.localizedDescription)
            }, onCompleted: {
                print("Completed")
            }, onDisposed: nil)
            .disposed(by: disposeBag)
    }
    
    private func convertDataToDataSourceModel(_ model: [(String, Article)]) -> [SectionOfArticles] {
        var sectionArray = [SectionOfArticles]()
        var tempArray = [Article]()
        var tempDate = model.first?.0 ?? ""
        
        model.forEach { (date, article) in
            if tempDate == date {
                tempArray.append(article)
            } else {
                sectionArray.append(SectionOfArticles(header: tempDate, items: tempArray))
                tempDate = date
                tempArray.removeAll()
                
                tempArray.append(article)
            }
        }
        sectionArray.append(SectionOfArticles(header: tempDate, items: tempArray))
        return sectionArray
    }
    
    private func index(of header: String) -> Int? {
        let articlesSectionValue = articlesSection.value
        
        for (index, item) in articlesSectionValue.enumerated() {
            if item.header == header {
                return index
            }
        }
        return nil
    }
}
