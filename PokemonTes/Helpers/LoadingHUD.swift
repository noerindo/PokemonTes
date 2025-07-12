//
//  Loading.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import UIKit
import MBProgressHUD

final class LoadingHUD {
    
    /// Show loading HUD on specific view
    static func show(in view: UIView, text: String? = nil) {
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.mode = .indeterminate
            hud.label.text = text ?? "Loading..."
        }
    }

    /// Hide loading HUD from specific view
    static func hide(from view: UIView) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
}
