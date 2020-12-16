//
//  NewsCoordinator.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 15.12.2020.
//

import UIKit

class NewsCoordinator: Coordinator {
    weak var mainCoordinator: Coordinator?
    var navigationController: UINavigationController
    
    init(presenter: UINavigationController, mainCoordinator: Coordinator) {
        navigationController = presenter
        self.mainCoordinator = mainCoordinator
    }
    
    func start() {
        let newsViewController = NewsViewController()
        newsViewController.viewModel = NewsViewModel()
        navigationController.pushViewController(newsViewController, animated: true)
    }
}
