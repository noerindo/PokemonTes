//
//  SceneDelegate.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        // Ambil LoginViewController dari Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")

        // Bungkus dengan NavigationController
        let navController = UINavigationController(rootViewController: loginVC)
        window.rootViewController = navController
        self.window = window
        window.makeKeyAndVisible()
    }
}
