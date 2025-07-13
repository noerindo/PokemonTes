//
//  HomeViewModel.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class HomeViewModel {
    // MARK: - Dependencies
    private let apiService = GenerateApiExt.shared
    private let disposeBag = DisposeBag()
    
    // MARK: - Pagination State
    private var isFirstLoad = true
    private var offset = 0
    private let limit = 20
    
    // MARK: - Data Storage
    private var currentPokemons: [DetailPokemonModel] = []
    
    // MARK: - Outputs
    private let pokemonsRelay = BehaviorRelay<[DetailPokemonModel]>(value: [])
    var pokemons: Observable<[DetailPokemonModel]> {
        return pokemonsRelay.asObservable()
    }
    
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    var isLoading: Observable<Bool> {
        return loadingRelay.asObservable()
    }
    var isLoadingValue: Bool {
        return loadingRelay.value
    }
    
    let errorMessage = PublishRelay<String>()
    
    var onLoadingDetail: ((Bool) -> Void)?
    
    func fetchPokemon() {
        loadingRelay.accept(true)
        var fetchSingle: Single<[DetailPokemonModel]>
        
        if isFirstLoad {
            isFirstLoad = false
            fetchSingle = apiService.getPokemons()
                .flatMap { [unowned self] in self.fetchDetailPokemons(from: $0.pokemons) }
        } else {
            fetchSingle = apiService.getMorePokemon(offset: offset)
                .flatMap { [unowned self] in self.fetchDetailPokemons(from: $0.pokemons) }
        }
        
        fetchSingle
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] details in
                    guard let self = self else { return }
                    self.currentPokemons += details
                    self.pokemonsRelay.accept(self.currentPokemons)
                    self.offset = self.currentPokemons.count
                    
                    self.loadingRelay.accept(false)
                },
                onFailure: { [weak self] error in
                    self?.loadingRelay.accept(false)
                    let message = error.localizedDescription.isEmpty ? "Unknown error" : error.localizedDescription
                    self?.errorMessage.accept(message)
                }
            )
            .disposed(by: disposeBag)
    }
    
    // MARK: - Fetch Pokémons with Details (Reactive)
    private func fetchDetailPokemons(from list: [Pokemon]) -> Single<[DetailPokemonModel]> {
        let detailSingles = list.compactMap {
            apiService.getDetailPokemon(url: $0.urlPokemon ?? "")
        }
        return Single.zip(detailSingles)
    }
    
    
    func fetchImagePokemon(from urlPokemon: Int) -> Single<UIImage> {
        return Single<UIImage>.create { single in
            
            guard let url = PokemonUtils.getPokemonImageURL(from: urlPokemon) else {
                let placeholder = UIImage(systemName: "heart.fill") ?? UIImage()
                single(.success(placeholder))
                return Disposables.create()
            }
            
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        single(.success(image))
                    }
                } else {
                    let fallback = UIImage(systemName: "heart.fill") ?? UIImage()
                    DispatchQueue.main.async {
                        single(.success(fallback))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    func didSelectPokemon(_ pokemon: DetailPokemonModel, completion: @escaping (DetailPokemonModel) -> Void) {
        onLoadingDetail?(true)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            DispatchQueue.main.async {
                self.onLoadingDetail?(false)
                completion(pokemon)
            }
        }
    }
    
}
