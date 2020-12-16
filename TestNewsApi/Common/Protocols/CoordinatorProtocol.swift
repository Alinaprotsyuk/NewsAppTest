//
//  CoordinatorProtocol.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 14.12.2020.
//

import Foundation
import RxSwift
import UIKit
 
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }

    func start()
}
