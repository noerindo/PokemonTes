//
//  PokemonUtils.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import Foundation
import UIKit

struct PokemonUtils {
    static func extractPokemonID(from url: String) -> Int? {
        let trimmedURL = url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return Int(trimmedURL.components(separatedBy: "/").last ?? "")
    }
    
    static func getPokemonImageURL(from id: Int, isGif: Bool = false) -> URL? {
        return URL(string: isGif ? "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/\(id).gif" : "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
    }
    
    static func createTypeLabel(text: String, bgColor: UIColor, height: CGFloat = 24) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize:  height == 24 ? 12 : 20, weight: .medium)
        label.textColor = .white
        label.backgroundColor = bgColor
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        label.snp.makeConstraints { make in
            make.height.equalTo(height)
            make.width.greaterThanOrEqualTo(60)
        }
        
        return label
    }
}
