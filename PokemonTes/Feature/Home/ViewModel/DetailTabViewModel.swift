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

struct DetailTabViewItem {
    var id: Int
    var title: String
    var contentType: DetailTabContentType
    
}

protocol DetailViewModelProtocol {
    var getData: [DetailTabViewItem] { get }
}

final class DetailTabViewModel: DetailViewModelProtocol {
    var item: DetailPokemonModel
    
    var getData: [DetailTabViewItem] {
        let detailTab: [(DetailTabContentType)] = [
            (.abilities(item.abilities)),
            (.baseXP(item.base)),
            (.types(item.types))
        ]
        return detailTab.map { contentType in
            DetailTabViewItem(id: item.id ?? 0, title: item.name ?? "Pokemon", contentType: contentType)
        }
        
    }
    
    init(_ item: DetailPokemonModel) {
        self.item = item
    }
}

extension DetailTabViewItem {
    var typesList: [Types]? {
        if case let .types(data) = contentType {
            return data
        }
        return nil
    }
    
    var typeNameValue: String {
        typesList?.first?.type.name ?? "normal"
    }
}

