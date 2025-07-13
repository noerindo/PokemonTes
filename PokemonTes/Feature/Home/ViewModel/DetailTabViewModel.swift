//
//  DetailTabViewModel.swift
//  PokemonTes
//
//  Created by Phincon on 13/07/25.
//

import Foundation
import SwiftUICore

enum DetailTabContentType {
    case abilities([Abilitys])
    case baseXP(Int)
    case types([Types])
}

class DetailTabViewModel {
    let id: Int
    let title: String
    let contentType: DetailTabContentType
    
    init(id: Int, title: String, contentType: DetailTabContentType) {
        self.id = id
        self.title = title
        self.contentType = contentType
    }
}
