//
//  DIContainer.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 14.12.2020.
//

import Foundation
import Swinject

class DIContainer {
    enum ContainerKeys: String {
        case apiClient
    }
    
    private static let container = Container()
    
    static func register<T>(name: String, value: T) {
        container.register(type(of: value), name: name) { _ in value }
    }
    
    static func resolve<T>(service: T.Type, name: String) -> T? {
        return container.resolve(service, name: name)
        
    }
}

