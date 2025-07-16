//
//  extension.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import UIKit

extension UITextField {
    static func inputFormField(placeholder: String, isSecure: Bool = false)-> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.boldSystemFont(ofSize: 15)
        textField.borderStyle = .roundedRect
        if isSecure {
            textField.isSecureTextEntry = true
            textField.enablePasswordToggle()
        }
        return textField
    }
    
    func enablePasswordToggle() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        button.addTarget(self, action: #selector(togglePasswordView), for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    
    @objc private func togglePasswordView(_ sender: UIButton) {
        self.isSecureTextEntry.toggle()
        
        let imageName = self.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
        
        let currentText = self.text
        self.text = nil
        self.text = currentText
    }
}

extension UIColor {
    static func backgroundColorForType(_ type: String, isBlur: Bool = false) -> UIColor {
        switch type.lowercased() {
        case "water": return .systemBlue.withAlphaComponent(isBlur ? 0.3 : 1)
        case "ice": return .systemTeal.withAlphaComponent(isBlur ? 0.3 : 1)
        case "fire": return .systemRed.withAlphaComponent(isBlur ? 0.3 : 1)
        case "grass": return .systemGreen.withAlphaComponent(isBlur ? 0.3 : 1)
        case "electric": return .systemYellow.withAlphaComponent(isBlur ? 0.3 : 1)
        case "bug": return .systemTeal.withAlphaComponent(isBlur ? 0.3 : 1)
        case "flying": return .systemIndigo.withAlphaComponent(isBlur ? 0.3 : 1)
        case "psychic": return .systemPink .withAlphaComponent(isBlur ? 0.3 : 1)
        case "dragon": return .systemOrange.withAlphaComponent(isBlur ? 0.3 : 1)
        case "dark": return .darkGray.withAlphaComponent(isBlur ? 0.3 : 1)
        case "steel": return .systemGray.withAlphaComponent(isBlur ? 0.3 : 1)
        case "fairy": return .systemPink.withAlphaComponent(isBlur ? 0.3 : 1)
        default: return .gray.withAlphaComponent(isBlur ? 0.3 : 1)
        }
    }
}

extension UILabel {
    static  func labelGeneral(text: String = "") -> UILabel  {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15)
        return label
    }
}

extension UIImageView {
    static func imagePokemon() -> UIImageView {
        let imgPoke = UIImageView()
        imgPoke.image = UIImage(named: "pokeball")
        imgPoke.contentMode = .scaleAspectFit
        return imgPoke
    }
}
