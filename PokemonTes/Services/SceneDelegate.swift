//
//  SceneDelegate.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        let rootVC: UIViewController = isLoggedIn ? MainTabViewController() : LoginViewController()
//        let rootVC: UIViewController =  LoginViewController()
        
        window?.rootViewController = UINavigationController(rootViewController: rootVC)
        window?.makeKeyAndVisible()
    }
}

