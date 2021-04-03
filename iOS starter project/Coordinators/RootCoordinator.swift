//
//  RootCoordinator.swift
//  iOS starter project
//
//  Created by Davide Ceresola on 03/04/21.
//

import UIKit

class RootCoordinator {
    
    private weak var window: UIWindow?
    
    private lazy var rootController = RootViewController()
    
    init(window: UIWindow) {
        self.window = window
        
        window.rootViewController = rootController
        window.makeKeyAndVisible()
    }
    
    func start() {
        
    }
    
}
