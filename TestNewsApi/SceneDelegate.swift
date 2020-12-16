//
//  SceneDelegate.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 14.12.2020.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: MainCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        coordinator = MainCoordinator(window: window)
        self.window = window
        
        coordinator?.start()
    }
}

