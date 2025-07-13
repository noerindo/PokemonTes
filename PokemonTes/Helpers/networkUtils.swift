//
//  networkUtils.swift
//  PokemonTes
//
//  Created by Phincon on 13/07/25.
//

import Foundation
import Alamofire

struct NetworkUtils {
    static var isConnected: Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
