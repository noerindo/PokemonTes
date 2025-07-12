//
//  SnackBar.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import SnackBar_swift

class SnackBarWarning: SnackBar {
    
    override var style: SnackBarStyle {
        var style = SnackBarStyle()
        style.background = .red
        style.textColor = .white
        return style
    }
}
class SnackBarSuccess: SnackBar {
    
    override var style: SnackBarStyle {
        var style = SnackBarStyle()
        style.background = .green
        style.textColor = .white
        return style
    }
}
