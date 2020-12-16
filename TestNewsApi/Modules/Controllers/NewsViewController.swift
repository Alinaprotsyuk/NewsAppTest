//
//  ViewController.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 14.12.2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class NewsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfArticles>!
    var viewModel: NewsViewModel!
    
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPullToRefresh()
        createNavSearchController()
        configureTableView()
        
        setupTableViewDataSource()
        setupTableViewDelegate()
        
        searchController.searchBar.rx.text.orEmpty
            .throttle(.microseconds(3000), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (text) in
                self?.viewModel.getNews(from: text, page: 1)
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.articlesSection
            .subscribe(onNext: { [weak self] (articles) in
                self?.tableView.refreshControl?.endRefreshing()
            }).disposed(by: viewModel.disposeBag)
        
        viewModel.articlesSection
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
        
        viewModel.hideRefreshControl
            .subscribe { [weak self] (hide) in
                if self?.tableView.refreshControl?.isRefreshing ?? false {
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }.disposed(by: viewModel.disposeBag)
        
        viewModel.errorMessage
            .subscribe(onNext: { [weak self] message in
                guard let messageUnwrap = message else { return }
                self?.presentAlertController(with: messageUnwrap)
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    //MARK: - Private Functions
    private func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.prefetchDataSource = self
        
        tableView.register(UINib(nibName: NewsTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: NewsTableViewCell.identifier)
    }
    
    private func createNavSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type text for looking related news..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    private func presentAlertController(with message: String) {
        let actions: [UIAlertController.AlertAction] = [
            .action(title: "Ok")
        ]
        
        UIAlertController
            .present(in: self, title: "Error", message: message, style: .alert, actions: actions)
            .subscribe(onNext: { buttonIndex in
                print(buttonIndex)
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    @objc func refresh() {
        viewModel.getNews(from: searchController.searchBar.text ?? "", page: 1)
    }
}

//MARK: - UITableViewDataSource
extension NewsViewController {
    fileprivate func setupTableViewDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfArticles> (
            configureCell: { dataSource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier,
                                                               for: indexPath) as? NewsTableViewCell else { fatalError() }
                cell.setup(item)
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                return dataSource.sectionModels[index].header
            }
        )
    }
}

//MARK: - UITableViewDelegate
extension NewsViewController {
    fileprivate func setupTableViewDelegate() {
        dataSource.canEditRowAtIndexPath = { dataSource, indexPath  in
            return true
        }
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { self.viewModel.removeItem(at: $0) })
            .disposed(by: viewModel.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] (indexPath) in
                let section = indexPath.section
                let row = indexPath.row
                if let string = self?.viewModel.articlesSection.value[section].items[row].url,
                   let url = URL(string: string) {
                    UIApplication.shared.open(url)
                }
            })
            .disposed(by: viewModel.disposeBag)
        
    }
}

//MARK: - UITableViewDataSourcePrefetching
extension NewsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let lastSection = viewModel.articlesSection.value.last,
           indexPaths.last?.row ?? 0 >= lastSection.items.count - 1,
           let nextPage = viewModel.paginationModel.nextPage,
           let searchText = searchController.searchBar.text {
            viewModel.getNews(from: searchText, page: nextPage)
        }
    }
}
