//
//  CardViewModel.swift
//  PokemonTes
//
//  Created by Phincon on 14/07/25.
//

import Foundation

enum DisplayMode {
    case grid
    case list
}

struct CardPokemonViewModel {
    let id: Int
    let name: String
    let mode: DisplayMode
}

