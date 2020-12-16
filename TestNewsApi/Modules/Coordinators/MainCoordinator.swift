//
//  MainCoordinator.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 15.12.2020.
//

import UIKit

class MainCoordinator: Coordinator {
    let window: UIWindow
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        navigationController = UINavigationController()
        let newsCoordinator = NewsCoordinator(presenter: navigationController, mainCoordinator: self)
        childCoordinators.append(newsCoordinator)
    }
    
    func start() {  
        window.rootViewController = navigationController
        childCoordinators.first?.start()
        window.makeKeyAndVisible()
    }
}
