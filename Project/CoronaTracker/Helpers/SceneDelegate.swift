//
//  SceneDelegate.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    //MARK SAVE DATA BEFORE ENTERING BACKGROUND
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

