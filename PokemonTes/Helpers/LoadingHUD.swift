//
//  LoadingHUD.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import UIKit
import MBProgressHUD

final class LoadingHUD {
    
    static func show(in view: UIView, text: String? = nil) {
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.mode = .indeterminate
            hud.label.text = text ?? "Loading..."
        }
    }

    static func hide(from view: UIView) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
    
    static func hideAll() {
            guard let window = UIApplication.shared.windows.first else { return }
            MBProgressHUD.hide(for: window, animated: true)
        }
}
