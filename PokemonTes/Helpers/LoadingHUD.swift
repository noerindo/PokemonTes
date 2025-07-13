//
//  LoadingHUD.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import UIKit
import MBProgressHUD

final class LoadingHUD {
    
    static func show(in view: UIView, text: String = "Loading...") {
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.mode = .indeterminate
            hud.label.text = text
        }
    }
    
    static func hide(from view: UIView) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
    
    static func hideAll() {
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                MBProgressHUD.hide(for: keyWindow, animated: true)
            }
        }
    }
}
